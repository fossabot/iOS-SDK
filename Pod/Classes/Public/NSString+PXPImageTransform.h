//
//  NSString+PXPImageTransform.h
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import <Foundation/Foundation.h>

@class PXPTransform;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PXPImageTransform)

+ (NSString *)pxp_cdnUrl;
- (NSString * _Nullable)pxp_imagePath;
- (NSString *)pxp_urlStringForTransform:( PXPTransform* _Nullable )transform;

@end

NS_ASSUME_NONNULL_END
