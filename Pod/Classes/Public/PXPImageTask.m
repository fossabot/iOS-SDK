//
//  PXPImageTask.m
//  PixpieFramework
//
//  Created by Dmitry Osipa on 4/14/16.
//
//

#import "PXPImageTask.h"
#import "PXPImageRequestWrapper.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import "PXP.h"
#import "PXPTransform.h"
#import "NSString+PXPImageTransform.h"
#import "NSURL+PXPUrl.h"
#import "PXPImageRequestWrapper.h"
#import "AFHTTPSessionOperation.h"
#import "PXPSDKRequestWrapper.h"
#import "PXPDefines.h"
#import "NSOperationQueue+PXPExtensions.h"

@interface PXPImageTask ()

@property (nonatomic, strong) PXPImageRequestWrapper* requestWrapper;
@property (nonatomic, assign) NSInteger retryCount;

@end

@implementation PXPImageTask

#pragma mark - Public interface

- (instancetype)initWithUrl:(NSString *)urlString
                     method:(NSString *)method
                  transfrom:(PXPTransform *)transform
                     params:(nullable NSDictionary *)params
                    headers:(nullable NSDictionary *)headers
                 identifier:(NSString *)identifier
                      queue:(NSOperationQueue*)queue
             requestWrapper:(PXPImageRequestWrapper *)requestWrapper
             uploadProgress:(PXPProgressBlock)uploadProgress
           downloadProgress:(PXPProgressBlock)downloadProgress
                 completion:(PXPImageRequestCompletionBlock)completion {

    NSError *error = nil;
    PXPImageTask* task = nil;
    AFHTTPRequestSerializer<AFURLRequestSerialization> *serializer = requestWrapper.sessionManager.requestSerializer;
    NSURLRequest* request = [PXPImageTask requestWithUrlString:urlString method:method params:params headers:headers serializer:serializer error:&error];
    NSAssert(error == nil, @"Request serialization error");
    task = [self initWithRequest:request transfrom:transform identifier:identifier queue:queue requestWrapper:requestWrapper uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completion];
    return task;
}

- (instancetype)initWithRequest:(NSURLRequest*)request
                      transfrom:(PXPTransform*)transform
                     identifier:(NSString*)identifier
                          queue:(NSOperationQueue*)queue
                 requestWrapper:(PXPImageRequestWrapper*)requestWrapper
                 uploadProgress:(PXPProgressBlock)uploadProgress
               downloadProgress:(PXPProgressBlock)downloadProgress
                     completion:(PXPImageRequestCompletionBlock)completion {
    self = [super init];
    if (self != nil) {
        _originalRequest = request;
        _transform = transform;
        _queue = queue;
        _identifier = identifier;
        _requestWrapper = requestWrapper;
        _uploadProgress = uploadProgress;
        _downloadProgress = downloadProgress;
        _retryCount = 5;
        _completionBlock = ^(NSURL* _Nullable url, UIImage  * _Nullable responseObject, NSError * _Nullable error) {

            completion(url, responseObject, error);
            _executing = NO;
        };
    }
    return self;
}

- (PXPSDKRequestWrapper *)sdkRequestWrapper {
    return [PXP sharedSDK].wrapper;
}

- (void)start {
    if (self.isExecuting) return;
    _executing = YES;
    [self executeImageDownloadOperation];
}

- (void)cancel {
    if (!self.isExecuting) return;
    _executing = NO;
    NSArray<NSOperation*> *operations = [self.queue operationsForIdentifier:self.identifier];
    [operations makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark - Private Interface
#pragma mark - Request Flow

- (void)executeImageDownloadOperation {

    PXPUrlType urlType = [_originalRequest.URL pxp_URLType];
    if (urlType == PXPUrlTypeOther) {
        NSError* error = nil;
        _completionBlock(_originalRequest.URL, nil, error);
    }

    void(^successBlock)(NSURLSessionTask * _Nonnull, id  _Nullable) = ^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
        _completionBlock(task.originalRequest.URL, responseObject, nil);
    };
    void(^failtureBlock)(NSURLSessionTask * _Nonnull, id  _Nullable) = ^(NSURLSessionTask * _Nonnull task, NSError* _Nullable error) {
        _completionBlock(task.originalRequest.URL, nil, error);
    };
    if ([PXP sharedSDK].state != PXPStateReady) {
        [self addOriginalImageOperationWithSuccess:successBlock
                                          failture:failtureBlock];

    } else {
        __weak typeof(self)weakSelf = self;
        [self addPixpieImageOperationWithTransform:_transform
                                        retryCount:self.retryCount
                                           success:successBlock
                                          failture:^(NSURLSessionTask * _Nonnull task, NSError * _Nonnull error) {
                                              if (((NSHTTPURLResponse*)task.response).statusCode == 404) {
                                                  __strong __typeof(weakSelf)strongSelf = weakSelf;
                                                  [strongSelf addPreCacheOperationWithSuccessBlock:successBlock
                                                                                failureBlock:failtureBlock];
                                              } else {
                                                  failtureBlock(task, error);
                                              }
                                          }];
    }
}

- (void)addPreCacheOperationWithSuccessBlock:(PXPImageSuccessBlock)successBlock
                                failureBlock:(PXPImageFailureBlock)failtureBlock {

    PXPTransform* defaultTransform = [PXPTransform new];
    defaultTransform.fitSize = CGSizeMake(2048.0, 2048.0);
    defaultTransform.imageQuality = PXPTransformQualityDefault;
    defaultTransform.fitSizeStyle = PXPTransformFitSizeStyleManual;
    __weak typeof(self)weakSelf = self;
    [self addPixpieImageOperationWithTransform:defaultTransform
                                    retryCount: self.retryCount
                                       success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
                                           successBlock(task, responseObject);
                                           __strong __typeof(weakSelf)strongSelf = weakSelf;
                                           [strongSelf updateImage];
                                       }
                                      failture:^(NSURLSessionTask * _Nonnull task, NSError * _Nonnull error) {
                                          if (((NSHTTPURLResponse*)task.response).statusCode == 404) {
                                              __strong __typeof(weakSelf)strongSelf = weakSelf;
                                              [strongSelf addOriginalImageOperationWithSuccess:successBlock
                                                                                      failture:failtureBlock];

                                          } else {
                                              failtureBlock(task, error);
                                          }
                                      }];
}

- (void)updateImage {
    NSString* urlString = _originalRequest.URL.absoluteString;
    [self.sdkRequestWrapper updateImageWithWidth:_transform.sizeString
                                         quality:_transform.qualityString
                                            path:urlString.pxp_imagePath
                                    successBlock:^(NSURLSessionTask* task, id responseObject) {
                                        PXPLogInfo(@"Update Image OK: %@", urlString);
                                    } failtureBlock:^(NSURLSessionTask* task, NSError *error) {
                                        PXPLogError(@"Update Image Error: %@ : %@", error, urlString);
                                    }];
}

- (void)uploadImage {
    NSString* urlString = _originalRequest.URL.absoluteString;
    NSDictionary* params = self.originalRequest.allHTTPHeaderFields;
    [self.sdkRequestWrapper uploadImageTaskAtUrl:urlString
                                           width:_transform.sizeString
                                         quality:_transform.qualityString
                                          params:params
                                    successBlock:^(NSURLSessionTask* task, id responseObject) {
                                        PXPLogInfo(@"Remote Image Upload OK: %@, url: %@", responseObject, urlString);
                                    } failtureBlock:^(NSURLSessionTask* task, NSError *error) {
                                        PXPLogError(@"Remote Image Upload Error: %@, url: %@", error, urlString);
                                    }];
}

- (void)addPixpieImageOperationWithTransform:(PXPTransform*)transform retryCount:(NSInteger)retry
                                     success:(PXPImageSuccessBlock)successBlock
                                    failture:(PXPImageFailureBlock)failtureBlock {

    NSString* urlString = _originalRequest.URL.absoluteString;
    NSDictionary* headers = self.originalRequest.allHTTPHeaderFields;
    NSString* pxpUrlString = [urlString pxp_urlStringForTransform:transform];
    AFHTTPSessionOperation* imageDownloadOperation = [self.requestWrapper imageDownloadTaskForUrl:pxpUrlString
                                                                               method:@"GET"
                                                                           parameters:nil
                                                                              headers:headers
                                                                       uploadProgress:_uploadProgress
                                                                     downloadProgress:_downloadProgress
                                                                              success:successBlock
                                                                             failture:^(NSURLSessionTask * _Nonnull task, NSError * _Nonnull error) {
                                                                                 if (retry == 0 || !(error.code == NSURLErrorTimedOut && [error.domain isEqualToString:NSURLErrorDomain])) {
                                                                                     failtureBlock(task, error);
                                                                                 } else {
                                                                                     [self addPixpieImageOperationWithTransform:transform
                                                                                                                     retryCount:retry - 1
                                                                                                                        success:successBlock
                                                                                                                       failture:failtureBlock];
                                                                                 }
                                                                             }];

    [self addOperation:imageDownloadOperation];
}

- (void)addOriginalImageOperationWithSuccess:(PXPImageSuccessBlock)successBlock
                                    failture:(PXPImageFailureBlock)failtureBlock {

    AFHTTPSessionOperation* imageDownloadOperation = [self.requestWrapper imageDownloadTaskForRequest:_originalRequest
                                                                                       uploadProgress:_uploadProgress
                                                                                     downloadProgress:_downloadProgress
                                                                                              success:successBlock
                                                                                             failture:failtureBlock];
    if ([PXP sharedSDK].state == PXPStateReady) {
        [self uploadImage];
    }
    [self addOperation:imageDownloadOperation];
}

- (void)addOperation:(PXPAsynchronousOperation*)operation {
    operation.name = self.identifier;
    [self.queue addOperation:operation];
}

#pragma mark - Private Class Methods

+ (NSURLRequest*)requestWithUrlString:(NSString *)urlString
                               method:(NSString *)method
                               params:(NSDictionary *)params
                              headers:(NSDictionary *)headers
                           serializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)serializer
                                error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest* request = [serializer requestWithMethod:method URLString:urlString parameters:params error:error];
    for (NSString* key in headers.allKeys) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    return request;
}

@end
