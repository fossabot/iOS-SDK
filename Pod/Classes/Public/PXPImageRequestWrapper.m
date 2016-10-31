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

@interface PXPImageRequestWrapper ()

@property (nonatomic, weak) NSOperationQueue* queue;
@property (nonatomic, strong) PXPSDKRequestWrapper* sdkRequestWrapper;

@end

@implementation PXPImageRequestWrapper

- (instancetype)init {
    self = [self initWithSessionConfiguration:[PXPImageRequestWrapper defaultImageSessionConfiguration]];
    return self;
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)config {
    self = [super init];
    if (self != nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        AFImageResponseSerializer *serializer = [PXPWebPImageResponseSerializer serializer];
        _sessionManager.responseSerializer = serializer;
        _queue = [PXPQueueManager networkQueue];
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

    AFHTTPSessionOperation* task = [AFHTTPSessionOperation operationWithManager:self.sessionManager request:request uploadProgress:uploadProgress downloadProgress:downloadProgress success:successBlock failure:failtureBlock];
    [self.queue addOperation:task];
    return task;
}

#pragma mark - Helpers

+ (NSURLSessionConfiguration *)defaultImageSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = YES;

    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 15.0;
    configuration.HTTPMaximumConnectionsPerHost = 3;
    configuration.URLCache = nil;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.protocolClasses = @[[PXPHTTPProtocol class]];

    return configuration;
}

@end
