//
//  PXPDataMonitor.m
//  Pods
//
//  Created by Boris Polyakov on 7/5/16.
//
//

#import "PXPDataMonitor.h"
#import "PXPURLProtocol.h"
#import "PXPTrafficMonitor.h"
#import "PXPNetInfo.h"
#import "PXPNetworkMonitor.h"
#import "PXPNetworkTechnologies.h"
@import QuartzCore.CAAnimation;


static NSInteger const kPXPFrameDuration = 1.0;
static NSInteger const kPXPUndefined = -1;

/*
 * Source https://toolstud.io/data/bandwidth.php?compare=mobile
 * NSData is in bytes, values there are in *bits
 */

static NSUInteger const kPXPNormalizingCoeficient = 1;

static NSUInteger const kPXP2GGSMSpeed = 14400 / (8 * kPXPNormalizingCoeficient);
static NSUInteger const kPXP2GGPRSSpeed = 57600 / (8 * kPXPNormalizingCoeficient);
static NSUInteger const kPXP2GEdgeSpeed = 238800 / (8 * kPXPNormalizingCoeficient);
static NSUInteger const kPXP3GUTMSSpeed = 384800 / (8 * kPXPNormalizingCoeficient);
static NSUInteger const kPXP3GHSPASpeed = 13980000 / (8 * kPXPNormalizingCoeficient);
static NSUInteger const kPXP3GHSPAPSpeed = 4.2e+7 / (8 * kPXPNormalizingCoeficient);
static NSUInteger const kPXP4GLTESpeed = 1.73e+8 / (8 * kPXPNormalizingCoeficient);
static NSUInteger const kPXPWifiSpeed = 1e+7 / 8;


@interface PXPDataMonitor() <PXPURLProtocolDelegate>

@property (nonatomic) NSInteger frameBytesSum;
@property (nonatomic) NSInteger frameMaxSpeed;
@property (nonatomic) NSInteger frameChunkCount;

@property (nonatomic) CFTimeInterval lastFrameTime;
@property (nonatomic) CFTimeInterval currentFrameTime;
@property (nonatomic) CFTimeInterval lastDataTime;

@property (nonatomic) NSInteger throughput;
@property (nonatomic) NSInteger lastThroughput;

@property (atomic, readwrite, assign) PXPDataSpeed speedType;

@end

@implementation PXPDataMonitor

+ (instancetype)sharedMonitor
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        [PXPURLProtocol setDelegate:_sharedObject];
    });
    
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frameBytesSum = kPXPUndefined;
        self.frameChunkCount = kPXPUndefined;
        self.lastFrameTime = 0.0;
        self.currentFrameTime = 0.0;
        self.frameMaxSpeed = kPXPUndefined;
        self.lastThroughput = [PXPDataMonitor throughputForNetInfo];
        self.throughput = kPXPUndefined;
        [self updateSpeedType];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange) name:kPXPNetworkChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPXPNetworkChangedNotification object:nil];
}

+ (NSInteger)throughputForNetInfo {
    static NSDictionary* sPXPNetworkTechnologies = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPXPNetworkTechnologies = @{ PXPNetworkCDMAEVDORevB : @(kPXP2GEdgeSpeed),
                                     PXPNetworkCDMAEVDORevA : @(kPXP2GEdgeSpeed),
                                     PXPNetworkCDMAEVDORev0 : @(kPXP2GEdgeSpeed),
                                     PXPNetworkCDMA1x: @(kPXP3GUTMSSpeed),
                                     PXPNetworkWCDMA : @(kPXP3GUTMSSpeed),
                                     PXPNetworkHSUPA : @(kPXP3GHSPASpeed),
                                     PXPNetworkHSDPA : @(kPXP3GHSPASpeed),
                                     PXPNetworkeHRPD : @(kPXP3GHSPASpeed),
                                     PXPNetworkGPRS : @(kPXP2GGPRSSpeed),
                                     PXPNetworkEdge : @(kPXP2GEdgeSpeed),
                                     PXPNetworkLTE : @(kPXP4GLTESpeed),
                                     PXPNetworkWiFi : @(kPXPWifiSpeed) };
    });

    PXPNetworkMonitor* monitor = [PXPNetworkMonitor sharedMonitor];
    NSString* technology = monitor.currentNetworkTechnology.technology;
    if (technology == nil) {
        return 0;
    } else {
        NSNumber* value = sPXPNetworkTechnologies[technology];
        return value.integerValue;
    }
}

- (void)networkChange {
    self.throughput = [PXPDataMonitor throughputForNetInfo];
}

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol receivedBlockSize:(ssize_t)size
{
    NSInteger frame = CACurrentMediaTime();
    BOOL newFrame = fabs(self.currentFrameTime) < DBL_EPSILON || (frame - self.currentFrameTime) > kPXPFrameDuration;
    if (newFrame) {
        self.lastThroughput = self.throughput;
        [self updateSpeedType];
        self.frameChunkCount = 0;
        self.frameBytesSum = 0;
        self.currentFrameTime = CACurrentMediaTime();
        self.frameMaxSpeed = size;
    }
    
    self.frameChunkCount++;
    self.frameBytesSum += size;
    self.lastDataTime = CACurrentMediaTime();
    if (self.frameMaxSpeed < size) {
        self.frameMaxSpeed = size;
    }
    [self calculateSpeed];

    [[PXPTrafficMonitor sharedMonitor] performSelector:@selector(reportBlockSizes:) withObject:@(size)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PXPURLProtocolReceivedChunk" object:nil userInfo:@{@"chunkSize" : @(size)}];
}

- (void)calculateSpeed
{
    CFTimeInterval faticialFrameLength = (self.lastDataTime - self.currentFrameTime);
    if (faticialFrameLength > kPXPFrameDuration / 3.0) {
        NSInteger predictedChunkCount = (self.frameChunkCount / faticialFrameLength) / kPXPFrameDuration;
        NSInteger throughput = predictedChunkCount * self.frameMaxSpeed;
        self.throughput = throughput;
    }
}

- (void)updateSpeedType
{
    NSInteger throughput = self.lastThroughput;
    if (throughput == kPXPUndefined) {
        self.speedType = PXPDataSpeedIdle;
    } else if (throughput > kPXP3GHSPASpeed) {
        self.speedType = PXPDataSpeedExtraHigh;
    } else if (throughput > kPXP3GUTMSSpeed) {
        self.speedType = PXPDataSpeedHigh;
    } else if (throughput > kPXP2GEdgeSpeed) {
        self.speedType = PXPDataSpeedMedium;
    } else if (throughput > kPXP2GGPRSSpeed) {
        self.speedType = PXPDataSpeedLow;
    } else {
        self.speedType = PXPDataSpeedExtraLow;
    }
}

@end
