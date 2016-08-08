//
//  AsynchronousOperation.m
//

#import "PXPAsynchronousOperation.h"


@interface PXPAsynchronousOperation ()

@property (getter = isFinished, readwrite)  BOOL finished;
@property (getter = isExecuting, readwrite) BOOL executing;

@end

@implementation PXPAsynchronousOperation

@synthesize finished  = _finished;
@synthesize executing = _executing;

- (id)init {
    self = [super init];
    if (self) {
        _finished  = NO;
        _executing = NO;
    }
    return self;
}

- (void)start {

    self.executing = YES;
    [self main];
}

- (void)main {
    NSAssert(![self isMemberOfClass:[PXPAsynchronousOperation class]], @"AsynchronousOperation is abstract class that must be subclassed");
    NSAssert(false, @"AsynchronousOperation subclasses must override `main`.");
}
             
- (void)completeOperation {
    self.executing = NO;
    self.finished  = YES;
}

#pragma mark - NSOperation methods

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
//    @synchronized(self) {
        return _executing;
//    }
}

- (BOOL)isFinished {
//    @synchronized(self) {
        return _finished;
//    }
}

- (void)setExecuting:(BOOL)executing {
//    @synchronized(self) {
        if (_executing != executing) {
            [self willChangeValueForKey:@"isExecuting"];
            _executing = executing;
            [self didChangeValueForKey:@"isExecuting"];
        }
//    }
}

- (void)setFinished:(BOOL)finished {
//    @synchronized(self) {
        if (_finished != finished) {
            [self willChangeValueForKey:@"isFinished"];
            _finished = finished;
            [self didChangeValueForKey:@"isFinished"];
        }
//    }
}

@end
