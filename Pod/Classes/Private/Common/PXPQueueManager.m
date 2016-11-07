//
//  PXPQueueManager.m
//  Pods
//
//  Created by Dmitry Osipa on 9/14/16.
//
//

#import "PXPQueueManager.h"
#import "PXPDataMonitor.h"

@implementation PXPQueueManager

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [[PXPDataMonitor sharedMonitor] addObserver:self forKeyPath:@"speedType" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [[PXPDataMonitor sharedMonitor] removeObserver:self forKeyPath:@"speedType" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"speedType"] && object == [PXPDataMonitor sharedMonitor]) {
        [PXPQueueManager setupQueue:[PXPQueueManager networkQueue]];
    }
}

#pragma mark - Class Methods

+ (NSOperationQueue *)networkQueue {
    static dispatch_once_t onceToken;
    static NSOperationQueue* sQueue = nil;
    dispatch_once(&onceToken, ^{
        sQueue = [NSOperationQueue new];
        [PXPQueueManager setupQueue:sQueue];
    });
    return sQueue;
}

+ (void)setupQueue:(NSOperationQueue*)aQueue {
    PXPDataSpeed speed = [PXPDataMonitor sharedMonitor].speedType;
    NSOperationQueue* queue = aQueue;
    switch (speed) {
        case PXPDataSpeedUndefined:
            queue.maxConcurrentOperationCount = 4;
            break;
        case PXPDataSpeedExtraLow:
            queue.maxConcurrentOperationCount = 1;
            break;
        case PXPDataSpeedLow:
            queue.maxConcurrentOperationCount = 1;
            break;
        case PXPDataSpeedMedium:
            queue.maxConcurrentOperationCount = 4;
            break;
        case PXPDataSpeedHigh:
            queue.maxConcurrentOperationCount = 6;
            break;
        case PXPDataSpeedExtraHigh:
            queue.maxConcurrentOperationCount = 6;
            break;
        case PXPDataSpeedNone:
            queue.maxConcurrentOperationCount = 0;
            break;
        default:
            queue.maxConcurrentOperationCount = 6;
            break;
    }
}

@end
