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

static const NSInteger precisionConstant = 100;
static const NSInteger frameDuration = 1 * precisionConstant;

@interface PXPDataMonitor() <PXPURLProtocolDelegate>

@property (nonatomic) NSInteger frameBytesSum;
@property (nonatomic) NSInteger frameChunkCount;
@property (nonatomic) NSInteger lastFrame;
@property (nonatomic) NSInteger currentFrame;

@property (nonatomic) PXPDataSpeed lastMeasuredSpeed;

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
        self.frameBytesSum = -1;
        self.frameChunkCount = -1;
        self.lastFrame = -1;
        self.currentFrame = -1;
        self.lastMeasuredSpeed = PXPDataSpeedUndefined;
    }
    return self;
}

- (NSInteger)currentTimeInterval
{
    return [NSDate timeIntervalSinceReferenceDate] * precisionConstant;
}

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol receivedBlockSize:(ssize_t)size
{
    NSInteger frame = [self currentTimeInterval];
    BOOL newFrame = self.currentFrame == -1 || (frame - self.currentFrame) > frameDuration;
    if (newFrame) {
        [self calculateSpeed];
        self.currentFrame = frame;
    }
    
    self.frameChunkCount++;
    self.frameBytesSum += size;
    
    [[PXPTrafficMonitor sharedMonitor] performSelector:@selector(reportBlockSizes:) withObject:@(size)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PXPURLProtocolReceivedChunk" object:nil userInfo:@{@"chunkSize" : @(size)}];
}

- (void)calculateSpeed
{
    NSInteger avgChunkSize = self.frameBytesSum / self.frameChunkCount;
    if (avgChunkSize > 6 * 1<<10) {
        self.lastMeasuredSpeed = PXPDataSpeedExtraHigh;
    }
    else if (avgChunkSize > 5 * 1<<10) {
        self.lastMeasuredSpeed = PXPDataSpeedHigh;
    }
    else if (avgChunkSize > 4 * 1<<10) {
        self.lastMeasuredSpeed = PXPDataSpeedMedium;
    }
    else {
        self.lastMeasuredSpeed = PXPDataSpeedExtraLow;
    }
    self.frameChunkCount = 0;
    self.frameBytesSum = 0;
}

- (PXPDataSpeed)speedType
{
    if ([self currentTimeInterval] - self.currentFrame > frameDuration * 2) {
        return PXPDataSpeedIdle;
    }
    if ([self currentTimeInterval] - self.currentFrame > frameDuration) {
        [self calculateSpeed];
    }
    
    return self.lastMeasuredSpeed;
}

@end
