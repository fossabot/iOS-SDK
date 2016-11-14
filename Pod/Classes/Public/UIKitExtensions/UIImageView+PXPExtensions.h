//
//  UIImageView+PXPExtensions.h
//  Pixpie
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import <UIKit/UIKit.h>
#import "PXPImageRequestWrapper.h"

@class PXPTransform;
@class AFHTTPSessionOperation;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PXPImageRequestCompletionBlock)(NSURLSessionTask* task, id _Nullable responseObject, NSError  * _Nullable  error);


@interface UIImageView (PXPExtensions)

@property (nonatomic, strong, nullable) PXPTransform* pxp_transform;
@property (nonatomic, strong, nullable) AFHTTPSessionOperation* pxp_downloadTask;

- (void)pxp_requestImage:(NSString*)url;
- (void)pxp_requestImage:(NSString*)url headers:(NSDictionary * _Nullable )headers completion:(PXPImageRequestCompletionBlock _Nullable)completion;
- (void)pxp_cancelLoad;

@end

NS_ASSUME_NONNULL_END
