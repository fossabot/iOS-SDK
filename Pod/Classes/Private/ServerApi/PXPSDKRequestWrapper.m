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
#import "PXPAccountInfo.h"
#import "PXPAuthPrincipal.h"

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

- (NSURLSessionDataTask *)imagesAtPath:(NSString *)path
                          successBlock:(PXPRequestSuccessBlock)successBlock
                         failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPItemsInFolderRequestPath, self.appId, path];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];
    NSURLSessionDataTask *task = [self.sessionManager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failtureBlock(error);
    }];
    return task;
}

- (void)handleFailture:(NSURLSessionDataTask*)task successBlock:(PXPRequestSuccessBlock)successBlock
         failtureBlock:(PXPRequestFailureBlock)failtureBlock {
    [self.info update];
}

- (void)performRequest:(NSURLRequest*)request
            retryCount:(NSInteger)retryCount
             lastError:(NSError*)error
          successBlock:(PXPRequestFailureBlock)successBlock
         failtureBlock:(PXPRequestSuccessBlock)failureBlock
{
    if (retryCount <= 0)
    {
        BLOCK_SAFE_RUN(failureBlock, error);
    }
    else
    {
        __weak typeof(self)weakSelf = self;
        NSURLSessionTask* operation = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error == nil)
            {
                BLOCK_SAFE_RUN(successBlock, responseObject);
            }
            else
            {
                [strongSelf performRequest:request retryCount:retryCount - 1 lastError:error successBlock:successBlock failtureBlock:failureBlock];
            }
        }];
        [operation resume];
    }
}

@end
