//
//  UIImageView+PXPExtensions.h
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import <UIKit/UIKit.h>
#import "PXPImageTaskManager.h"

@class PXPTransform;

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (PXPExtensions)

@property (nonatomic, strong) PXPTransform* pxp_transform;
@property (nonatomic, strong) NSString* pxp_downloadTaskIdentifier;

- (void)pxp_requestImage:(NSURL*)url;
- (void)pxp_requestImage:(NSURL*)url headers:(NSDictionary * _Nullable )headers completion:(PXPImageRequestCompletionBlock _Nullable)completion;
- (void)pxp_requestImageForPath:(NSString*)path completion:(PXPImageRequestCompletionBlock _Nullable)completion;
- (void)cancelLoad;

@end

NS_ASSUME_NONNULL_END
