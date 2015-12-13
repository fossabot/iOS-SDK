//
//  UIImageView+PXPExtensions.h
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import <UIKit/UIKit.h>


@class PXPTransform;

@interface UIImageView (PXPExtensions)

@property (nonatomic, strong) PXPTransform* pxp_transfrom;

- (void)pxp_requestImage:(NSURL*)url;
- (void)pxp_requestImageNamed:(NSString*)name;

@end
