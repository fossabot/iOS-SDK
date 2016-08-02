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

static NSInteger const kPXPFrameDuration = 1.0;
static NSInteger const kPXPUndefined = -1;

@interface PXPDataMonitor() <PXPURLProtocolDelegate>

@property (nonatomic) NSInteger frameBytesSum;
@property (nonatomic) NSInteger frameMaxSpeed;
@property (nonatomic) NSInteger frameChunkCount;

@property (nonatomic) CFTimeInterval lastFrameTime;
@property (nonatomic) CFTimeInterval currentFrameTime;
@property (nonatomic) CFTimeInterval lastDataTime;

@property (nonatomic) NSInteger lastThroughput;

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
        self.lastThroughput = kPXPUndefined;
    }
    return self;
}

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol receivedBlockSize:(ssize_t)size
{
    NSInteger frame = CACurrentMediaTime();
    BOOL newFrame = fabs(self.currentFrameTime) < DBL_EPSILON || (frame - self.currentFrameTime) > kPXPFrameDuration;
    if (newFrame) {
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
        self.lastThroughput = throughput;
    }
}

- (PXPDataSpeed)speedType
{
    NSInteger throughput = self.lastThroughput;
    if (throughput == kPXPUndefined) {
        return PXPDataSpeedIdle;
    } else if (throughput > 630000) {
        return PXPDataSpeedExtraHigh;
    } else if (throughput > 440000) {
        return PXPDataSpeedHigh;
    } else if (throughput > 48000) {
        return PXPDataSpeedMedium;
    } else if (throughput > 29000) {
        return PXPDataSpeedLow;
    }
    return PXPDataSpeedExtraLow;
}

@end
