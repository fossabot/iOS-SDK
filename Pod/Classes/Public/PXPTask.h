//
//  PXPTask.h
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^PXPImageDownloadRequestCompletionBlock)(UIImage  * _Nullable responseObject, NSError * _Nullable error);
typedef void (^PXPImageUploadRequestCompletionBlock)(id _Nullable responseObject, NSError * _Nullable error);

@class PXPTransform;
@class PXPSDKRequestWrapper;
@class PXPImageRequestWrapper;

typedef enum : NSUInteger {
    PXPTaskStateStopped,
    PXPTaskStateInProgress,
    PXPTaskStateComplete
} PXPTaskState;

NS_ASSUME_NONNULL_BEGIN

@interface PXPTask : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL*)url
                  transform:(PXPTransform*)transform
          sdkRequestWrapper:(PXPSDKRequestWrapper*)sdkRequestWrapper
        imageRequestWrapper:(PXPImageRequestWrapper*)imageRequestWrapper
            processingQueue:(NSOperationQueue*)processingQueue
              callbackQueue:(NSOperationQueue*)callbackQueue
                 completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;
- (void)start;
- (void)cancel;

@property (nonatomic, readonly) PXPTaskState state;

@end

NS_ASSUME_NONNULL_END
