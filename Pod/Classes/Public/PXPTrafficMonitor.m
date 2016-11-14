//
//  PXPTrafficMonitor.m
//  Pixpie
//
//  Created by Boris Polyakov on 7/7/16.
//
//

#import "PXPTrafficMonitor.h"
#import "PXPDefines.h"

@interface PXPTrafficMonitor()

@property (nonatomic, assign, readwrite) NSUInteger totalBytes;
@property (nonatomic, strong) NSMutableArray *minuteSamples;

@property (nonatomic, strong) NSTimer *sliderTimer;
@property (nonatomic) NSUInteger currentFrameBytes;

@property (nonatomic, strong) dispatch_queue_t monitorQueue;
@end

@implementation PXPTrafficMonitor

+ (instancetype)sharedMonitor
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        const char * identifier = PXP_IDENTIFY_CLASS(self.class).UTF8String;
        self.monitorQueue =  dispatch_queue_create(identifier, DISPATCH_QUEUE_CONCURRENT);

        self.totalBytes = 0;
        self.currentFrameBytes = 0;
        self.minuteSamples = [NSMutableArray arrayWithCapacity:60];
        for (NSInteger i = 0; i < 60; i++) {
            [self.minuteSamples addObject:@(0)];
        }
        
        NSInteger ct = [NSDate timeIntervalSinceReferenceDate];

        NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate:(ct + 1)];
        self.sliderTimer = [[NSTimer alloc] initWithFireDate:d interval:1.f target:self selector:@selector(slideArray) userInfo:nil repeats:YES];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:self.sliderTimer forMode: NSDefaultRunLoopMode];
    }
    return self;
}

- (void)reportBlockSizes:(NSNumber *)blockSize
{
    dispatch_async(self.monitorQueue, ^{
        self.currentFrameBytes += blockSize.integerValue;
        self.totalBytes += blockSize.integerValue;
    });
}

- (void)slideArray
{
    dispatch_async(self.monitorQueue, ^{
        [self.minuteSamples removeObjectAtIndex:0];
        [self.minuteSamples addObject:@(self.currentFrameBytes)];
        self.currentFrameBytes = 0;
    });
}

- (NSArray *)dataSamples
{
    return [[NSArray alloc] initWithArray:self.minuteSamples copyItems:YES];
}

- (NSNumber *)lastSample
{
    __block NSNumber* result = nil;
    dispatch_sync(self.monitorQueue, ^{
        result = self.minuteSamples.lastObject;
    });
    return result;
}

- (void)reset {
    self.totalBytes = 0;
    self.currentFrameBytes = 0;
}

@end
