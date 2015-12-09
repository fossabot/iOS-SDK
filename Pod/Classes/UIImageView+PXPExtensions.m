//
//  UIImageView+PXPExtensions.m
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import "UIImageView+PXPExtensions.h"
#import "PXPTransform.h"
#import <objc/runtime.h>

@implementation UIImageView (PXPExtensions)

@dynamic transfrom;

- (void)setTransfrom:(PXPTransform *)transform {
    NSString* key = NSStringFromSelector(@selector(transfrom));
    objc_setAssociatedObject(self, (__bridge const void *)(key), transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PXPTransform*)transfrom {
    NSString* key = NSStringFromSelector(@selector(transfrom));
    PXPTransform* transform = objc_getAssociatedObject(self, (__bridge const void *)(key));
    if (transform == nil) {
        transform = [PXPTransform new];
        transform.fitSize = self.bounds.size;
        objc_setAssociatedObject(self, (__bridge const void *)(key), transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return transform;
}

- (void)pxp_requestImageNamed:(NSString*)name {
    self.class
}

@end
