//
//  PXPImageRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPImageRequestWrapper.h"
#import "AFNetworking.h"
#import "PXPWebPResponseSerializer.h"
#import "AFAutoPurgingImageCache.h"

@interface PXPImageRequestWrapper ()

@property (nonatomic, strong) AFHTTPSessionManager* sessionManager;
@property (nonatomic, strong, nullable) id <AFImageRequestCache> imageCache;

@end

@implementation PXPImageRequestWrapper

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[PXPImageRequestWrapper defaultImageSessionConfiguration]];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];

        NSArray <id<AFURLResponseSerialization>> *responseSerializers = @[[AFImageResponseSerializer serializer], [PXPWebPResponseSerializer serializer]];
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];

        _sessionManager.responseSerializer = serializer;
    }
    return self;
}

- (NSURLSessionDataTask *)imageTaskForUrl:(NSURL *)url
                               completion:(PXPImageRequestCompletionBlock)completionBlock {

    NSURLSessionDataTask *task = [self.sessionManager GET:url.absoluteString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];
    return task;
}


#pragma mark - Helpers

+ (NSURLSessionConfiguration *)defaultImageSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

#warning set the default HTTP headers

    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;

    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    configuration.URLCache = [PXPImageRequestWrapper defaultURLCache];

    return configuration;
}

+ (NSURLCache *)defaultURLCache {
    return [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                         diskCapacity:150 * 1024 * 1024
                                             diskPath:@"co.pixpie.imagecache"];
}

@end
