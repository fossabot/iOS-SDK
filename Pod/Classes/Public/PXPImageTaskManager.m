//
//  PXPImageDownloader.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPImageTaskManager.h"
#import "PXPSDKRequestWrapper.h"
#import "PXPTransform.h"
#import "NSURL+PXPUrl.h"
#import "NSString+PXPImageTransform.h"
#import "PXPImageRequestWrapper.h"
#import "PXP_Internal.h"
#import "PXPDefines.h"
#import "PXPImageTask.h"
#import "NSOperationQueue+PXPExtensions.h"
//@import UIKit.UIGraphics;

void PXPRunOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}



@interface PXPImageTaskManager ()

@property (nonatomic, strong) PXPImageRequestWrapper* imageRequestWrapper;
@property (nonatomic, strong, readonly) PXPSDKRequestWrapper* sdkRequestWrapper;

@end

@implementation PXPImageTaskManager

#pragma mark - Public Interface

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _imageRequestWrapper = [PXPImageRequestWrapper new];
    }
    return self;
}

- (NSString*)imageDownloadTaskWithUrl:(NSURL *)url
                            transform:(PXPTransform *)transform
                              headers:(NSDictionary * _Nullable)headers
                       uploadProgress:(PXPProgressBlock _Nullable)uploadProgress
                     downloadProgress:(PXPProgressBlock _Nullable)downloadProgress
                           completion:(PXPImageRequestCompletionBlock)completionBlock {
    return [self imageDownloadTaskWithPath:url.absoluteString transform:transform headers:headers uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completionBlock];
}

- (NSString*)imageDownloadTaskWithPath:(NSString *)path
                             transform:(PXPTransform *)transform
                               headers:(NSDictionary * _Nullable)headers
                        uploadProgress:(PXPProgressBlock _Nullable)uploadProgress
                      downloadProgress:(PXPProgressBlock _Nullable)downloadProgress
                            completion:(PXPImageRequestCompletionBlock)completionBlock {
    NSString* identifier = [[NSUUID UUID] UUIDString];
    PXPImageTask* task = [[PXPImageTask alloc] initWithUrl:path method:@"GET" transfrom:transform params:nil headers:headers identifier:identifier requestWrapper:self.imageRequestWrapper uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completionBlock];
    [task start];
    return identifier;
}

- (NSString*)imageDownloadTaskWithRequest:(NSURLRequest *)request
                                transform:(PXPTransform *)transform
                           uploadProgress:(PXPProgressBlock)uploadProgress
                         downloadProgress:(PXPProgressBlock)downloadProgress
                               completion:(PXPImageRequestCompletionBlock)completionBlock {
    NSString* identifier = [[NSUUID UUID] UUIDString];
    PXPImageTask* task = [[PXPImageTask alloc] initWithRequest:request transfrom:transform identifier:identifier requestWrapper:self.imageRequestWrapper uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completionBlock];
    [task start];
    return identifier;
}

- (NSString*)imageUploadTaskWithImage:(UIImage *)image
                                 path:(NSString *)path
                       uploadProgress:(PXPProgressBlock)uploadProgress
                           completion:(PXPImageRequestCompletionBlock)completionBlock {
    NSString* identifier = [[NSUUID UUID] UUIDString];
    NSURLSessionDataTask *task = [[PXP sharedSDK].wrapper uploadImageTaskForImage:image toPath:path successBlock:^(NSURLSessionTask *task, id responseObject) {
        if (completionBlock) {
            completionBlock(nil, nil, nil);
        }
    } failtureBlock:^(NSURLSessionTask *task, NSError *error) {
        if (completionBlock) {
            completionBlock(nil, nil, error);
        }
    }];
    [task resume];
    return identifier;
}

- (NSString *)imageUploadTaskWithImage:(UIImage *)image
                        uploadProgress:(PXPProgressBlock)uploadProgress
                            completion:(PXPImageRequestCompletionBlock)completionBlock {
#warning Must return identifier to cancel uploading
    NSString* identifier = [[NSUUID UUID] UUIDString];
    [self imageUploadTaskWithImage:image path:[NSString stringWithFormat:@"%@.jpg", identifier] uploadProgress:uploadProgress completion:completionBlock];
    return identifier;
}

- (void)cancelTaskWithIdentifier:(NSString*)identifier {
    NSArray* operations = [[PXPRequestWrapper networkQueue] operationsForIdentifier:identifier];
    [operations makeObjectsPerformSelector:@selector(cancel)];
}

@end
