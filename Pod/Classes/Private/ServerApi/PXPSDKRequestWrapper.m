//
//  PXPSDKRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPSDKRequestWrapper.h"
#import "PXPDefines.h"
#import "PXPAccountInfo.h"
#import "PXPAuthPrincipal.h"
#import "NSURL+PXPUrl.h"
#import <AFNetworking/AFNetworking.h>
#import "PXPAPITask.h"

static NSString* const kPXPUpdateImageRequestPath = @"/async/images/newResolution/%@/%@/%@/%@";
static NSString* const kPXPUploadImageRequestPath = @"/async/images/upload/%@/%@";
static NSString* const kPXPUploadImageAtUrlRequestPath = @"/async/storage/upload/remoteImage/%@";
static NSString* const kPXPItemsInFolderRequestPath = @"/storage/list/%@/%@";

@interface PXPSDKRequestWrapper ()

@property (nonatomic, weak) PXPAccountInfo *info;

@end

@implementation PXPSDKRequestWrapper

- (instancetype)initWithAccountInfo:(PXPAccountInfo *)info
{
    self = [super init];
    if (self != nil) {
        self.info = info;
    }
    return self;
}

- (void)setInfo:(PXPAccountInfo *)info {
    if (_info != info) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPXPModelUpdatedNotification object:_info];
        _info = info;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authInfoUpdate:) name:kPXPModelUpdatedNotification object:_info];
    }
}

- (NSString*)appId {
    return self.info.principal.appId;
}

- (void)authInfoUpdate:(NSNotification *)note {

    PXPAccountInfo* info = note.object;
    if (info.authToken.length > 0) {
        [self.sessionManager.requestSerializer setValue:info.authToken forHTTPHeaderField:@"AuthToken"];
    }
}

- (PXPAPITask *)updateImageWithWidth:(NSString*)width
                             quality:(NSString*)quality
                                path:(NSString*)path
                        successBlock:(PXPRequestSuccessBlock)successBlock
                       failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUpdateImageRequestPath, self.appId, width, quality, path];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];

    NSError* error = nil;
    NSMutableURLRequest* request = [self.sessionManager.requestSerializer requestWithMethod:@"POST" URLString:requestUrl parameters:nil error:&error];
    assert(error == nil);
    PXPAPITask *task = [self taskWithRequest:request successBlock:successBlock failtureBlock:failtureBlock];
    return task;
}

- (NSURLSessionDataTask *)uploadImageTaskForImage:(UIImage *)image
                                           toPath:(NSString *)path
                                     successBlock:(PXPRequestSuccessBlock)successBlock
                                    failtureBlock:(PXPRequestFailureBlock)failtureBlock {
    assert(path != nil);
    assert(image != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUploadImageRequestPath, self.appId, path];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];
    NSURLSessionDataTask *task = [self.sessionManager POST:requestUrl
                                                parameters:nil
                                 constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                     NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
                                     [formData appendPartWithFileData:imageData name:@"image" fileName:path.lastPathComponent mimeType:@"image/jpeg"];
                                 }
                                                  progress:nil
                                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                       if (successBlock) {
                                                           successBlock(task, responseObject);
                                                       }
                                                   }
                                                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                       if (failtureBlock) {
                                                           failtureBlock(task, error);
                                                       }
                                                   }];
    return task;

}

- (NSURLSessionDataTask *)uploadImageTaskForStream:(NSInputStream *)stream
                                          mimeType:(NSString *)mimeType
                                            length:(int64_t)length
                                            toPath:(NSString *)path
                                      successBlock:(PXPRequestSuccessBlock)successBlock
                                     failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUploadImageRequestPath, self.appId, path];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];
    NSURLSessionDataTask *task = [self.sessionManager POST:requestUrl
                                                parameters:nil
                                 constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                     [formData appendPartWithInputStream:stream name:@"image" fileName:@"image" length:length mimeType:mimeType];
                                 }
                                                  progress:nil
                                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                       successBlock(task, responseObject);
                                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                       failtureBlock(task, error);
                                                   }];
    return task;
}

- (PXPAPITask *)uploadImageTaskAtUrl:(NSString *)url
                               width:(NSString *)width
                             quality:(NSString *)quality
                              params:(NSDictionary*)requestHeaders
                        successBlock:(PXPRequestSuccessBlock)successBlock
                       failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(url != nil);
    if ([url pxp_URLType] == PXPUrlTypeCDN) {
        successBlock(nil, nil);
    }
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
    NSDictionary* headers = [PXPSDKRequestWrapper apiParamsFromHeaders:requestHeaders];
    for (NSString* key in headers.allKeys) {
        [params setObject:headers[key] forKey:key];
    }

    NSError* error = nil;
    NSMutableURLRequest* request = [self.sessionManager.requestSerializer requestWithMethod:@"POST" URLString:requestUrl parameters:params error:&error];
    assert(error == nil);
    PXPAPITask *task = [self taskWithRequest:request successBlock:^(NSURLSessionTask* task, id responseObject) {
        successBlock(task, responseObject);
    } failtureBlock:^(NSURLSessionTask* task, NSError *error) {
        failtureBlock(task, error);
    }];
    return task;
}

- (PXPAPITask *)imagesAtPath:(NSString *)path
                successBlock:(PXPRequestSuccessBlock)successBlock
               failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPItemsInFolderRequestPath, self.appId, path];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];

    NSError* error = nil;
    NSMutableURLRequest* request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:requestUrl parameters:nil error:&error];
    assert(error == nil);
    PXPAPITask *task = [self taskWithRequest:request successBlock:successBlock failtureBlock:failtureBlock];
    return task;
}

- (PXPAPITask *)taskWithRequest:(NSURLRequest *)request
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(self.sessionManager != nil);
    __weak typeof(self)weakSelf = self;
    NSString *uuid = [[NSUUID UUID] UUIDString];
    PXPAPITask *task = [[PXPAPITask alloc] initWithRequest:request queue:self.operationQueue identifier:uuid sessionManager:self.sessionManager evaluationBlock:^BOOL(NSURLSessionTask *task, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        if (response.statusCode == 403 || response.statusCode == 401) {
            [strongSelf.info update];
        }
        return YES;
    } success:successBlock failure:^(NSURLSessionTask* task, NSError *error) {
        BLOCK_SAFE_RUN(failtureBlock, task, error);
    }];
    [task start];
    return task;
}

+ (NSDictionary*)apiParamsFromHeaders:(NSDictionary*)headers {

    NSMutableDictionary* params = [NSMutableDictionary new];
    NSString* authValue = headers[@"Authorization"];
    SAFE_SET_OBJECT(params, @"authorizationHeader", authValue);
    return params;
}

@end
