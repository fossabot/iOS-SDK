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

@interface PXPImageRequestWrapper ()

@property (nonatomic, strong) AFHTTPSessionManager* sessionManager;
@property (nonatomic, strong, nullable) id <AFImageRequestCache> imageCache;

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
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSArray <id<AFURLResponseSerialization>> *responseSerializers = @[[AFImageResponseSerializer serializer], [PXPWebPResponseSerializer serializer]];
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
        _sessionManager.responseSerializer = serializer;
    }
    return self;
}

- (NSURLSessionDataTask *)imageDownloadTaskForUrl:(NSURL *)url
                                       parameters:(NSDictionary * _Nullable )headers
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    NSError *error = nil;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:url.absoluteString parameters:nil error:&error];
    assert(error == nil);
    for (NSString* key in headers.allKeys) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    return [self imageDownloadTaskForRequest:request completion:completionBlock];
}

- (NSURLSessionDataTask *)imageDownloadTaskForRequest:(NSURLRequest *)request
                                           completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    NSURLSessionDataTask* task = [self.sessionManager dataTaskWithRequest:request
//                                                           uploadProgress:nil
//                                                         downloadProgress:nil
                                                        completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error == nil) {
            completionBlock(request.URL, responseObject, nil);
        } else {
            completionBlock(request.URL, nil, error);
        }
    }];
    [task resume];
    return task;
}

#pragma mark - Helpers

+ (NSURLSessionConfiguration *)defaultImageSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;

    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    configuration.URLCache = [PXPImageRequestWrapper defaultURLCache];

    return configuration;
}

+ (NSURLCache *)defaultURLCache {
    return [[NSURLCache alloc] initWithMemoryCapacity: 20 * 1024 * 1024
                                         diskCapacity: 150 * 1024 * 1024
                                             diskPath:@"co.pixpie.imagecache"];
}

@end
