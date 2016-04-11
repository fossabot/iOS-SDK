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
@import UIKit.UIGraphics;

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
@property (nonatomic, strong) NSOperationQueue* imageTransformQueue;

@end

@implementation PXPImageTaskManager

#pragma mark - Public Interface

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _imageRequestWrapper = [PXPImageRequestWrapper new];
        _imageTransformQueue = [NSOperationQueue new];
    }
    return self;
}

- (PXPSDKRequestWrapper *)sdkRequestWrapper {
    return [PXP sharedSDK].wrapper;
}

- (NSURLSessionDataTask*)imageDownloadTaskWithUrl:(NSURL*)url
                                        transform:(PXPTransform*)transform
                                          headers:(NSDictionary * _Nullable)headers
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    PXPUrlType urlType = [url pxp_URLType];
    if (urlType == PXPUrlTypePath && self.sdkRequestWrapper != nil) {
        return [self imageDownloadTaskWithPath:url.path.pxp_imagePath transform:transform completion:^(NSURL* anUrl, UIImage * _Nullable responseObject, NSError * _Nullable error) {
            PXPRunOnMainQueueWithoutDeadlocking(^{
                completionBlock(url, responseObject, error);
            });
        }];
    } else if (urlType == PXPUrlTypeRemote && self.sdkRequestWrapper != nil) {
        return [self imageDownloadWithRemoteUrl:url transform:transform headers:headers completion:^(NSURL* anUrl, UIImage * _Nullable responseObject, NSError * _Nullable error) {
            PXPRunOnMainQueueWithoutDeadlocking(^{
                completionBlock(url, responseObject, error);
            });
        }];
    } else {
        __weak typeof(self)weakSelf = self;
        return [self imageDownloadTaskWithUrl:url headers:headers completion:^(NSURL* anUrl, UIImage * _Nullable responseObject, NSError * _Nullable error) {
//            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (responseObject != nil) {
//                [strongSelf applyTransfrom:transform toImage:responseObject completion:^(NSURL* theUrl, UIImage * _Nullable responseObject, NSError * _Nullable error) {
                    PXPRunOnMainQueueWithoutDeadlocking(^{
                        completionBlock(url, responseObject, error);
                    });
//                }];
            } else {
                PXPRunOnMainQueueWithoutDeadlocking(^{
                    completionBlock(url, nil, error);
                });
            }
        }];
    }
    return nil;
}

- (NSURLSessionDataTask*)imageDownloadTaskWithPath:(NSString*)path
                                         transform:(PXPTransform*)transform
                                        completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    NSString* urlString = [path pxp_urlStringForTransform:transform];
    PXPImageDownloadRequestCompletionBlock block = ^(NSURL* url, UIImage* responseObject, NSError* error) {
        if (error == nil) {
            completionBlock(url, responseObject, nil);
        } else {
//            NSAssert([responseObject isKindOfClass:[UIImage class]], @"Response is not an UIImage");
            NSURL* url = [NSURL URLWithString:[path pxp_urlStringForTransform:nil]];
            [self imageDownloadTaskWithUrl:url  headers:nil completion:completionBlock];
            [self.sdkRequestWrapper updateImageWithWidth:transform.sizeString quality:transform.qualityString path:url.path.pxp_imagePath successBlock:^(id responseObject) {
                NSLog(@"OK: %@", responseObject);
            } failtureBlock:^(NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    };
    NSURLSessionDataTask* task = [self imageDownloadTaskWithUrl:[NSURL URLWithString:urlString]  headers:nil completion:block];
    return task;
}

- (NSURLSessionDataTask*)imageDownloadWithRemoteUrl:(NSURL*)url
                                          transform:(PXPTransform*)transform
                                            headers:(NSDictionary * _Nullable)params
                                         completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    NSString* urlString = [url.absoluteString pxp_urlStringForTransform:transform];
    PXPImageDownloadRequestCompletionBlock block = ^(NSURL* anUrl, UIImage* responseObject, NSError* error) {
        if (error == nil) {
            completionBlock(anUrl, responseObject, error);
        } else {
//            __weak typeof(self)weakSelf = self;
//            NSAssert([responseObject isKindOfClass:[UIImage class]], @"Response is not an UIImage");
            [self imageDownloadTaskWithUrl:url headers:params completion:^(NSURL* theUrl, UIImage * _Nullable responseObject, NSError * _Nullable error) {
                //__strong __typeof(weakSelf)strongSelf = weakSelf;
                if (responseObject != nil) {
//                    [strongSelf applyTransfrom:transform toImage:responseObject completion:completionBlock];
//                    NSAssert([responseObject isKindOfClass:[UIImage class]], @"Response is not an UIImage");
                    completionBlock(url, responseObject, nil);
                } else {
                    completionBlock(url, nil, error);
                }
            }];
            [self.sdkRequestWrapper uploadImageTaskAtUrl:url.absoluteString width:transform.sizeString quality:transform.qualityString params:params successBlock:^(id responseObject) {
                PXPLogInfo(@"Remote Image Upload OK: %@, url: %@", responseObject, url.absoluteString);
            } failtureBlock:^(NSError *error) {
                PXPLogError(@"Remote Image Upload Error: %@, url: %@", error, url.absoluteString);
            }];
        }
    };
    NSURLSessionDataTask* task = [self imageDownloadTaskWithUrl:[NSURL URLWithString:urlString] headers:params completion:block];
    return task;
}

#pragma mark - Private Interface

- (NSURLSessionDataTask*)imageDownloadTaskWithUrl:(NSURL*)url
                                          headers:(NSDictionary * _Nullable)headers
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {
    return [self.imageRequestWrapper imageDownloadTaskForUrl:url parameters:headers completion:completionBlock];
}

//- (void)applyTransfrom:(PXPTransform*)transform toImage:(UIImage*)image completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {
//    CGSize size = transform.fitSize;
//    CGSize currentSize = image.size;
//    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
//        UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
//
//        float hfactor = currentSize.width / size.width;
//        float vfactor = currentSize.height / size.height;
//
//        float factor = fmax(hfactor, vfactor);
//        float newWidth = currentSize.width / factor;
//        float newHeight = currentSize.height / factor;
//        
//        [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        completionBlock(newImage, nil);
//    }];
//    [self.imageTransformQueue addOperation:operation];
//    completionBlock(image, nil);
//}

@end
