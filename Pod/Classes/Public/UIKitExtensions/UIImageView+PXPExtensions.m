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
#import "PXPImageDownloader.h"

@implementation UIImageView (PXPExtensions)

@dynamic pxp_transfrom;

- (void)setPxp_transfrom:(PXPTransform *)transform {
    NSString* key = NSStringFromSelector(@selector(pxp_transfrom));
    objc_setAssociatedObject(self, (__bridge const void *)(key), transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PXPTransform*)pxp_transfrom {
    NSString* key = NSStringFromSelector(@selector(pxp_transfrom));
    PXPTransform* transform = objc_getAssociatedObject(self, (__bridge const void *)(key));
    if (transform == nil) {
        transform = [PXPTransform new];
        transform.fitSize = self.bounds.size;
        objc_setAssociatedObject(self, (__bridge const void *)(key), transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return transform;
}

- (void)pxp_requestImage:(NSURL*)url {
    [[PXPImageDownloader sharedDownloader] imageTaskWithUrl:url transform:self.pxp_transfrom completion:^(UIImage *responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = responseObject;
        });
    }];
}

- (void)pxp_requestImageNamed:(NSString*)name {
    
}

@end
