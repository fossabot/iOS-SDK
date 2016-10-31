//
//  PXPImageRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPImageRequestWrapper.h"
#import "PXPWebPResponseSerializer.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFAutoPurgingImageCache.h>
#import "AFHTTPSessionOperation.h"
#import "PXPHTTPProtocol.h"
#import "PXPQueueManager.h"
#import "PXPSDKRequestWrapper.h"
#import "PXP.h"
#import "PXP_Internal.h"
#import "PXPImageCache.h"

@interface PXPImageRequestWrapper ()

@property (nonatomic, weak) NSOperationQueue* queue;
@property (nonatomic, strong) PXPSDKRequestWrapper* sdkRequestWrapper;
@property (nonatomic, strong) PXPImageCache* cache;

@end

@implementation PXPImageRequestWrapper

- (instancetype)init {
    self = [self initWithSessionConfiguration:[PXPImageRequestWrapper defaultImageSessionConfiguration] cache:[PXPImageCache new]];
    return self;
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)config cache:(PXPImageCache*)cache {
    self = [super init];
    if (self != nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        AFImageResponseSerializer *serializer = [PXPWebPImageResponseSerializer serializer];
        _sessionManager.responseSerializer = serializer;
        _queue = [PXPQueueManager networkQueue];
        _cache = cache;
    }
    return self;
}

- (AFHTTPSessionOperation *)imageDownloadTaskForUrl:(NSString *)urlString
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                            success:(PXPImageSuccessBlock)successBlock
                                           failture:(PXPImageFailureBlock)failtureBlock {

    NSError *error = nil;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:nil error:&error];
    return [self imageDownloadTaskForRequest:request
                              uploadProgress:uploadProgress
                            downloadProgress:downloadProgress
                                     success:successBlock
                                    failture:failtureBlock];
}

- (AFHTTPSessionOperation *)imageDownloadTaskForRequest:(NSURLRequest *)request
                                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                       downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                                success:(PXPImageSuccessBlock)successBlock
                                               failture:(PXPImageFailureBlock)failtureBlock  {

    AFHTTPSessionOperation* task = nil;
    UIImage* image = [self.cache cachedImageForRequest:request];
    if (image == nil) {
        task = [AFHTTPSessionOperation operationWithManager:self.sessionManager request:request uploadProgress:uploadProgress downloadProgress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable object) {
            [self.cache cacheImage:object forRequest:request];
            successBlock(task, image);
        } failure:failtureBlock];
        [self.queue addOperation:task];
    } else {
        successBlock(nil, image);
    }
    return task;
}

#pragma mark - Helpers

+ (NSURLSessionConfiguration *)defaultImageSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = YES;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 15.0;
    configuration.HTTPMaximumConnectionsPerHost = 3;
    configuration.URLCache = nil;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.protocolClasses = @[[PXPHTTPProtocol class]];

    return configuration;
}

@end
