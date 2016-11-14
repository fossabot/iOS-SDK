//
//  PXPAPIManager.m
//  Pixpie
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPAPIManager.h"
#import "PXPDefines.h"
#import "PXPAccountInfo.h"
#import "PXPAuthPrincipal.h"
#import <AFNetworking/AFNetworking.h>
#import "PXPAPITask.h"
#import "PXPQueueManager.h"

static NSString* const kPXPUploadImageRequestPath = @"/async/images/upload/%@/%@";
static NSString* const kPXPItemsInFolderRequestPath = @"/storage/list/%@/%@";
static NSString* const kPXPDeleteItemAtPath = @"/storage/delete/batch/%@";

@interface PXPAPIManager ()

@property (nonatomic, weak) PXPAccountInfo *info;

@end

@implementation PXPAPIManager

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
        [self.sessionManager.requestSerializer setValue:info.authToken forHTTPHeaderField:@"pixpieAuthToken"];
    }
}

- (NSURLSessionDataTask *)uploadTaskForImage:(UIImage *)image
                                      toPath:(NSString *)path
                                successBlock:(PXPRequestSuccessBlock)successBlock
                               failureBlock:(PXPRequestFailureBlock)failureBlock {
    assert(path != nil);
    assert(image != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUploadImageRequestPath, self.appId, path];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];
    NSURLSessionDataTask *task = [self.sessionManager POST:requestUrl
                                                parameters:nil
                                 constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                     NSData *imageData = UIImageJPEGRepresentation(image, [UIScreen mainScreen].scale);
                                     [formData appendPartWithFileData:imageData name:@"image" fileName:path.lastPathComponent mimeType:@"image/jpeg"];
                                 }
                                                  progress:nil
                                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                       if (successBlock) {
                                                           successBlock(task, responseObject);
                                                       }
                                                   }
                                                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                       if (failureBlock) {
                                                           failureBlock(task, error);
                                                       }
                                                   }];
    return task;

}

- (NSURLSessionDataTask *)uploadImageTaskForStream:(NSInputStream *)stream
                                          mimeType:(NSString *)mimeType
                                            length:(int64_t)length
                                            toPath:(NSString *)path
                                      successBlock:(PXPRequestSuccessBlock)successBlock
                                     failureBlock:(PXPRequestFailureBlock)failureBlock {

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
                                                       failureBlock(task, error);
                                                   }];
    return task;
}

- (NSURLSessionDataTask *)imagesAtPath:(NSString *)path
                          successBlock:(PXPRequestSuccessBlock)successBlock
                         failureBlock:(PXPRequestFailureBlock)failureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPItemsInFolderRequestPath, self.appId, path];
    NSString* requestUrl = [self.backendUrl stringByAppendingString:apiPath];
    NSURLSessionDataTask *task = [self.sessionManager GET:requestUrl parameters:nil progress:nil success:successBlock failure:failureBlock];
    return task;
}

- (NSURLSessionDataTask * _Nullable)deleteImages:(NSArray<NSString*> * _Nonnull )images
                                            dirs:(NSArray<NSString*> * _Nonnull )dirs
                                    successBlock:(PXPRequestSuccessBlock)successBlock
                                   failureBlock:(PXPRequestFailureBlock)failureBlock {

    NSString* apiPath = [NSString stringWithFormat:kPXPDeleteItemAtPath, self.appId];
    NSMutableDictionary* params = [NSMutableDictionary new];
    SAFE_SET_OBJECT(params, @"images", images);
    SAFE_SET_OBJECT(params, @"folders", dirs);
    if ([params count] == 0) return nil;
    NSURLSessionDataTask* task = [self.sessionManager DELETE:apiPath
                                                  parameters:params
                                                     success:successBlock
                                                     failure:failureBlock];
    return task;
}

- (PXPAPITask *)taskWithRequest:(NSURLRequest *)request
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failureBlock:(PXPRequestFailureBlock)failureBlock {

    assert(self.sessionManager != nil);
    __weak typeof(self)weakSelf = self;
    NSString *uuid = [NSUUID UUID].UUIDString;
    PXPAPITask *task = [[PXPAPITask alloc] initWithRequest:request queue:[PXPQueueManager networkQueue] identifier:uuid sessionManager:self.sessionManager evaluationBlock:^BOOL(NSURLSessionTask *task, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        if (response.statusCode == 403 || response.statusCode == 401) {
            [strongSelf.info update];
            return YES;
        } else {
            return (error.code == NSURLErrorTimedOut && [error.domain isEqualToString:NSURLErrorDomain]);
        }
    } success:successBlock failure:^(NSURLSessionTask* task, NSError *error) {
        BLOCK_SAFE_RUN(failureBlock, task, error);
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
