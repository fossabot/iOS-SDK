//
//  PXPTask.m
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import "PXPTask.h"
#import "PXPSDKRequestWrapper.h"
#import "PXPImageRequestWrapper.h"
#import "PXPTransform.h"

@interface PXPTask ()

@property (nonatomic, strong) NSURL* url; // task identifier
@property (nonatomic, weak) PXPSDKRequestWrapper* sdkRequestWrapper;
@property (nonatomic, weak) PXPImageRequestWrapper* imageRequestWrapper;
@property (nonatomic, weak) NSURLSessionTask* currentTask;
@property (nonatomic, weak) NSOperation* currentOperation;
@property (nonatomic, weak) NSOperationQueue* processingQueue;
@property (nonatomic, weak) NSOperationQueue* callbackQueue;
@property (nonatomic, copy) PXPImageDownloadRequestCompletionBlock completionBlock;

@end

@implementation PXPTask

- (instancetype)initWithURL:(NSURL*)url
                  transform:(PXPTransform*)transform
          sdkRequestWrapper:(PXPSDKRequestWrapper*)sdkRequestWrapper
        imageRequestWrapper:(PXPImageRequestWrapper*)imageRequestWrapper
            processingQueue:(NSOperationQueue*)processingQueue
              callbackQueue:(NSOperationQueue*)callbackQueue
                 completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    self = [super init];
    if (self != nil) {
        _url = url;
        _imageRequestWrapper = imageRequestWrapper;
        _sdkRequestWrapper = sdkRequestWrapper;
        _processingQueue = processingQueue;
        _callbackQueue = callbackQueue;
        _completionBlock = completionBlock;
    }
    return self;
}

- (void)start {
    
}

- (void)cancel {

}

#pragma mark - Private Interface

- (NSURLSessionDataTask*)imageDownloadTaskWithUrl:(NSURL*)url
                                           params:(NSDictionary * _Nullable)params
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    return [self.imageRequestWrapper imageDownloadTaskForUrl:url parameters:params completion:completionBlock];
}

- (void)applyTransfrom:(PXPTransform*)transform toImage:(UIImage*)image completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    CGSize size = transform.fitSize;
    CGSize currentSize = image.size;
    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
        UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);

        float hfactor = currentSize.width / size.width;
        float vfactor = currentSize.height / size.height;

        float factor = fmax(hfactor, vfactor);
        float newWidth = currentSize.width / factor;
        float newHeight = currentSize.height / factor;

        [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        completionBlock(newImage, nil);
    }];
    [self.processingQueue addOperation:operation];
}

@end
