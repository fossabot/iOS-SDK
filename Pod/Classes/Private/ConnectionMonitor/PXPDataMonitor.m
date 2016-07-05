//
//  PXPDataMonitor.m
//  Pods
//
//  Created by Boris Polyakov on 7/5/16.
//
//

#import "PXPDataMonitor.h"
#import "PXPURLProtocol.h"

@interface PXPDataMonitor() <PXPURLProtocolDelegate>

@property (nonatomic, strong) NSMutableDictionary *responsesSamples;

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
        self.responsesSamples = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSTimeInterval)currentTimeInterval
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSArray *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    NSTimeInterval ti = [[cal dateFromComponents:comps] timeIntervalSinceReferenceDate];

    return ti;
}

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol receivedBlockSize:(ssize_t)size
{
    NSTimeInterval ti = [self currentTimeInterval];
    NSString *key = [NSString stringWithFormat:@"%f", ti];
    
    NSNumber *currentSize = self.responsesSamples[key];
    if (currentSize) {
        currentSize = @(currentSize.integerValue + size);
    }
    else {
        currentSize = @(size);
    }
    
    self.responsesSamples[key] = currentSize;
}

- (CGFloat)averageSpeedForInterval:(NSInteger)seconds
{
    NSTimeInterval ti = [self currentTimeInterval];
    CGFloat sum = 0;
    NSInteger _sec = 0;
    for (NSInteger i = 0; i < seconds; i++) {
        NSString *key = [NSString stringWithFormat:@"%f", ti - i];
        CGFloat sample = [self.responsesSamples[key] floatValue];
        sum += sample;
        _sec += sample != 0 ? 1 : 0;
    }
    return sum / _sec;
}

- (CGFloat)averageSpeedForSamples:(NSInteger)sampleCount
{
    NSArray *sampleKeys = [self.responsesSamples.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return ![obj1 compare:obj2];
    }];
    
    CGFloat sum = 0;
    NSInteger _samples = MIN(sampleCount, sampleKeys.count);
    for (NSInteger i = 0; i < _samples; i++) {
        NSString *key = sampleKeys[i];
        CGFloat sample = [self.responsesSamples[key] floatValue];
        sum += sample;
    }

    return sum / _samples;
}

- (PXPDataSpeed)speedType
{
    CGFloat currentAvgSpeed = [self averageSpeedForSamples:60];
    if (currentAvgSpeed >= PXPDataSpeedExtraHigh) {
        return PXPDataSpeedExtraHigh;
    }
    else if (currentAvgSpeed >= PXPDataSpeedHigh) {
        return PXPDataSpeedHigh;
    }
    else if (currentAvgSpeed >= PXPDataSpeedMedium) {
        return PXPDataSpeedMedium;
    }
    else if (currentAvgSpeed >= PXPDataSpeedLow) {
        return PXPDataSpeedLow;
    }
    else if (currentAvgSpeed >= PXPDataSpeedExtraLow){
        return PXPDataSpeedExtraLow;
    }
    else {
        return PXPDataSpeedUndefined;
    }
}

@end
