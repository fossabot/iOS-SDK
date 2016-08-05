//
//  AFHTTPSessionOperation.m
//
//  Created by Robert Ryan on 8/6/15.
//  Copyright (c) 2015 Robert Ryan. All rights reserved.
//

#import "AFHTTPSessionOperation.h"
#import "AFNetworking.h"
#import "PXPDefines.h"

@interface AFHTTPSessionManager (DataTask)

// this method is not publicly defined in @interface in .h, so we need to define our own interface for it

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end

@interface AFHTTPSessionOperation ()

@property (nonatomic, strong, readwrite, nullable) NSURLSessionTask *task;

@end

@implementation AFHTTPSessionOperation

+ (instancetype)operationWithManager:(AFHTTPSessionManager *)manager
                             request:(NSURLRequest *)request
                      uploadProgress:(void (^ _Nullable )(NSProgress *uploadProgress)) uploadProgress
                    downloadProgress:(void (^ _Nullable )(NSProgress *downloadProgress)) downloadProgress
                             success:(void (^)(NSURLSessionDataTask *, id))success
                             failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    AFHTTPSessionOperation *operation = [self new];
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (operation.isCancelled) {
            NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            BLOCK_SAFE_RUN(failure, dataTask, error);
        } else if (error) {
            BLOCK_SAFE_RUN(failure, dataTask, error);
        } else {
            BLOCK_SAFE_RUN(success, dataTask, responseObject);
        }
        [operation completeOperation];
    }];
    operation.task = dataTask;
    [operation startObservingStateChange];
    return operation;
}

- (void)startObservingStateChange {
    [self addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservingStateChange {
    @try {
        [self removeObserver:self forKeyPath:@"isCancelled"];
    }
    @catch (NSException * __unused exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isCancelled"]) {
        if (self.isCancelled) {
            [self.task cancel];
        }
    }
}

- (void)dealloc {
    [self stopObservingStateChange];
}

- (void)main {
    if (self.isCancelled) {
        [self.task cancel];
    } else {
        [self.task resume];
    }
}

@end
