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
@property (nonatomic, strong) NSOperationQueue* imageQueue;

@end

@implementation PXPImageTaskManager

#pragma mark - Public Interface

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _imageRequestWrapper = [PXPImageRequestWrapper new];
        _imageQueue = [NSOperationQueue new];
        _imageQueue.name = @"co.pixpie.ImageTaskManagerQueue";
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
    PXPImageTask* task = [[PXPImageTask alloc] initWithUrl:path method:@"GET" transfrom:transform params:nil headers:headers identifier:identifier queue:self.imageQueue requestWrapper:self.imageRequestWrapper uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completionBlock];
    [task start];
    return identifier;
}

- (NSString*)imageDownloadTaskWithRequest:(NSURLRequest *)request
                                transform:(PXPTransform *)transform
                           uploadProgress:(PXPProgressBlock)uploadProgress
                         downloadProgress:(PXPProgressBlock)downloadProgress
                               completion:(PXPImageRequestCompletionBlock)completionBlock {
    NSString* identifier = [[NSUUID UUID] UUIDString];
    PXPImageTask* task = [[PXPImageTask alloc] initWithRequest:request transfrom:transform identifier:identifier queue:self.imageQueue requestWrapper:self.imageRequestWrapper uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completionBlock];
    [task start];
    return identifier;
}

- (void)imageUploadTaskWithImage:(UIImage *)image
                                  path:(NSString *)path
                        uploadProgress:(PXPProgressBlock)uploadProgress
                            completion:(PXPImageRequestCompletionBlock)completionBlock {
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
}
- (void)imageUploadTaskWithImage:(UIImage *)image
                        uploadProgress:(PXPProgressBlock)uploadProgress
                            completion:(PXPImageRequestCompletionBlock)completionBlock {
    NSString* identifier = [[NSUUID UUID] UUIDString];
    [self imageUploadTaskWithImage:image path:[NSString stringWithFormat:@"%@.jpg", identifier] uploadProgress:uploadProgress completion:completionBlock];
}

- (void)cancelTaskWithIdentifier:(NSString*)identifier {
    NSArray* operations = [self.imageQueue operationsForIdentifier:identifier];
    [operations makeObjectsPerformSelector:@selector(cancel)];
}

@end
