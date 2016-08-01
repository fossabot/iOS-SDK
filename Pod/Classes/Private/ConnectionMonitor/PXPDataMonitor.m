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

static const NSInteger PXPPrecisionConstant = 1000;
static const NSInteger PXPFrameDuration = 1.0;

static NSInteger const PXPUndefined = -1;

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
        [PXPURLProtocol start];
    });
    
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frameBytesSum = PXPUndefined;
        self.frameChunkCount = PXPUndefined;
        self.lastFrameTime = 0.0;
        self.currentFrameTime = 0.0;
        self.frameMaxSpeed = PXPUndefined;
        self.lastThroughput = PXPUndefined;
    }
    return self;
}

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol receivedBlockSize:(ssize_t)size
{
    NSInteger frame = CACurrentMediaTime();
    BOOL newFrame = fabs(self.currentFrameTime) < DBL_EPSILON || (frame - self.currentFrameTime) > PXPFrameDuration;
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
    if (faticialFrameLength > PXPFrameDuration / 2.0) {
        NSInteger predictedChunkCount = (self.frameChunkCount / faticialFrameLength);
        NSInteger throughput = predictedChunkCount * self.frameMaxSpeed;
        self.lastThroughput = throughput;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Data %ld", (long)self.lastThroughput);
    });
//    if (self.frameChunkCount == 0) return;
//    NSInteger avgChunkSize = self.frameBytesSum / self.frameChunkCount;
//    if (avgChunkSize > 6 * 1 << 10 * faticialFrameLength / PXPPrecisionConstant) {
//        self.lastMeasuredSpeed = PXPDataSpeedExtraHigh;
//    } else if (avgChunkSize > 5 * 1 << 10 * faticialFrameLength / PXPPrecisionConstant) {
//        self.lastMeasuredSpeed = PXPDataSpeedHigh;
//    } else if (avgChunkSize > 4 * 1 << 10 * faticialFrameLength / PXPPrecisionConstant) {
//        self.lastMeasuredSpeed = PXPDataSpeedMedium;
//    } else {
//        self.lastMeasuredSpeed = PXPDataSpeedExtraLow;
//    }
//    self.frameChunkCount = 0;
//    self.frameBytesSum = 0;
}

- (PXPDataSpeed)speedType
{
    [self calculateSpeed];
    NSInteger throughput = self.lastThroughput;
    if (throughput == PXPUndefined) {
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
