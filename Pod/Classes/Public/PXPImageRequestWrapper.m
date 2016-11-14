//
//  PXPImageDownloader.m
//  Pixpie
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
#import "PXPAPIManager.h"
#import "PXP.h"
#import "PXP_Internal.h"
#import "PXPImageCache.h"
#import "PXPAuthChallengeManager.h"

@interface PXPImageDownloader ()

@property (nonatomic, weak) NSOperationQueue* queue;
@property (nonatomic, strong) PXPAPIManager* sdkRequestWrapper;
@property (nonatomic, strong) PXPImageCache* cache;

@end

@implementation PXPImageDownloader

- (instancetype)init {
    self = [self initWithSessionConfiguration:[PXPImageDownloader defaultImageSessionConfiguration] cache:[PXPImageCache new]];
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

- (void)cleanUp {
    [self.cache removeAllObjects];
}

- (AFHTTPSessionOperation *)imageDownloadTaskForUrl:(NSString *)urlString
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                            success:(PXPImageSuccessBlock)successBlock
                                           failure:(PXPImageFailureBlock)failureBlock {

    NSError *error = nil;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:nil error:&error];
    return [self imageDownloadTaskForRequest:request
                              uploadProgress:uploadProgress
                            downloadProgress:downloadProgress
                                     success:successBlock
                                    failure:failureBlock];
}

- (AFHTTPSessionOperation *)imageDownloadTaskForRequest:(NSURLRequest *)request
                                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                       downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                                success:(PXPImageSuccessBlock)successBlock
                                               failure:(PXPImageFailureBlock)failureBlock  {

    AFHTTPSessionOperation* task = nil;
    UIImage* image = [self.cache cachedImageForRequest:request];
    if (image == nil) {
        task = [AFHTTPSessionOperation operationWithManager:self.sessionManager request:request uploadProgress:uploadProgress downloadProgress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable object) {
            [self.cache cacheImage:object forRequest:request];
            successBlock(task, object);
        } failure:failureBlock];
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
    configuration.URLCache = nil;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.protocolClasses = @[[PXPHTTPProtocol class]];

    return configuration;
}

@end
