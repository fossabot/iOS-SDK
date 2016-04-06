//
//  PXPImageRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPImageRequestWrapper.h"
#import "PXPWebPResponseSerializer.h"
@import AFNetworking.AFNetworkReachabilityManager;
@import AFNetworking;

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
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    NSError *error = nil;
    NSURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:url.absoluteString parameters:nil error:&error];
    assert(error == nil);
    NSURLSessionDataTask* task = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error == nil) {
            completionBlock(responseObject, nil);
        } else {
            completionBlock(nil, error);
        }
    }];
    [task resume];
    return task;
}

#pragma mark - Helpers

+ (NSURLSessionConfiguration *)defaultImageSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    ***REMOVED***

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
