//
//  PXPAPITask.m
//  Pods
//
//  Created by Dmitry Osipa on 4/25/16.
//
//

#import "PXPAPITask.h"
#import "PXP.h"
#import "PXPSDKRequestWrapper.h"
#import "NSOperationQueue+PXPExtensions.h"
#import <AFNetworking/AFNetworking.h>
#import "PXPDefines.h"
#import "AFHTTPSessionOperation.h"

@interface PXPAPITask ()

@property (nonatomic, weak) AFHTTPSessionManager *sessionManager;

@end

@implementation PXPAPITask

- (instancetype)initWithRequest:(NSURLRequest*)request
                          queue:(NSOperationQueue*)queue
                     identifier:(NSString*)identifier
                 sessionManager:(AFHTTPSessionManager*)sessionManager
                        success:(PXPRequestSuccessBlock)successBlock
                        failure:(PXPRequestFailureBlock)failureBlock {
    self = [super init];
    if (self != nil) {
        _originalRequest = request;
        _queue = queue;
        _identifier = identifier;
        _sessionManager = sessionManager;
        _successBlock = successBlock;
        _failureBlock = failureBlock;
        _retryCount = 5;
        _retryInterval = 5.0;
    }
    return self;
}

- (void)start {
    if (self.isExecuting) return;
    _executing = YES;
    [self performRequestWithRetryCount:self.retryCount
                             lastError:nil];
}

- (void)cancel {
    if (!self.isExecuting) return;
    _executing = NO;
    NSArray<NSOperation*> *operations = [self.queue operationsForIdentifier:self.identifier];
    [operations makeObjectsPerformSelector:@selector(cancel)];
}

- (void)performRequestWithRetryCount:(NSInteger)retryCount
                           lastError:(NSError*)error
{
    if (retryCount <= 0 || !self.isExecuting)
    {
        BLOCK_SAFE_RUN(self.failureBlock, error);
        _executing = NO;
    }
    else
    {
        NSAssert(self.sessionManager, @"Session manager must be initialized");
        __weak typeof(self)weakSelf = self;
        __block NSOperation* operation = nil;
        operation = [AFHTTPSessionOperation operationWithManager:self.sessionManager request:self.originalRequest uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            BLOCK_SAFE_RUN(strongSelf.successBlock, responseObject);
            _executing = NO;
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            NSOperation* dummyOperation = [NSBlockOperation blockOperationWithBlock:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(strongSelf.retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (!dummyOperation.isCancelled) {
                        [strongSelf performRequestWithRetryCount:retryCount - 1 lastError:error];
                    }
                });
            }];
            dummyOperation.name = self.identifier;
            [strongSelf.queue addOperation:dummyOperation];
        }];
        operation.name = self.identifier;
        [self.queue addOperation:operation];
    }
}

@end
