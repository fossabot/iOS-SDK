//
//  PXPSDKRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPSDKRequestWrapper.h"
#import "AFNetworking.h"
#import "PXPDefines.h"

static NSString* const kPXPUpdateImageRequestPath = @"/images/newResolution/%@/%@/%@/%@";
static NSString* const kPXPUploadImageRequestPath = @"/images/upload/%@/%@";
static NSString* const kPXPUploadImageAtUrlRequestPath = @"/storage/upload/remoteImage/%@";

@interface PXPSDKRequestWrapper ()

@property (nonatomic, strong, readonly) NSString* appId;
@property (nonatomic, strong, readonly) NSString* token;

@end

@implementation PXPSDKRequestWrapper

- (instancetype)initWithAuthToken:(NSString*)token appId:(NSString*)appId
{
    self = [super init];
    if (self != nil) {
        [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"AuthToken"];
        _appId = appId;
        _token = token;
    }
    return self;
}

- (void)updateImageWithWidth:(NSString*)width
                     quality:(NSString*)quality
                        path:(NSString*)path
                successBlock:(PXPRequestSuccessBlock)successBlock
               failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUpdateImageRequestPath, self.appId, width, quality, path];
    NSString* url = [self.backendUrl stringByAppendingString:apiPath];
    [self.sessionManager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failtureBlock(error);
    }];
}

- (NSURLSessionDataTask *)uploadImageTaskForStream:(NSInputStream *)stream
                                          mimeType:(NSString *)mimeType
                                            length:(int64_t)length
                                            toPath:(NSString *)path
                                      successBlock:(PXPRequestSuccessBlock)successBlock
                                     failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUploadImageRequestPath, self.appId, path];
    NSString* url = [self.backendUrl stringByAppendingString:apiPath];
    NSURLSessionDataTask *task = [self.sessionManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithInputStream:stream name:@"image" fileName:@"image" length:length mimeType:mimeType];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failtureBlock(error);
    }];
    return task;
}

- (NSURLSessionDataTask *)uploadImageTaskAtUrl:(NSString*)url
                                         width:(NSString*)width
                                       quality:(NSString*)quality
                                  successBlock:(PXPRequestSuccessBlock)successBlock
                                 failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(url != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUploadImageAtUrlRequestPath, self.appId];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:url forKey:@"remoteImageUrl"];
    NSMutableDictionary* derivedImageSpecs = nil;
    if (width.length > 0 && quality.length > 0) {
        derivedImageSpecs = [NSMutableDictionary new];
        SAFE_SET_OBJECT(derivedImageSpecs, @"width", width);
        SAFE_SET_OBJECT(derivedImageSpecs, @"quality", quality);
    }
    SAFE_SET_OBJECT(params, @"derivedImageSpecs", derivedImageSpecs);
    NSURLSessionDataTask *task = [self.sessionManager POST:requestUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failtureBlock(error);
    }];
    return task;
}

@end
