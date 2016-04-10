//
//  UIImageView+PXPExtensions.h
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import <UIKit/UIKit.h>


@class PXPTransform;

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (PXPExtensions)

@property (nonatomic, strong) PXPTransform* pxp_transform;
@property (nonatomic, strong) NSURLSessionDataTask* pxp_downloadTask;

- (void)pxp_requestImage:(NSURL*)url;
- (void)pxp_requestImage:(NSURL*)url headers:(NSDictionary  * _Nullable )headers;
- (void)pxp_requestImageForPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
