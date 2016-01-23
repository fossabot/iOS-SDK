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
#import "PXPImageTaskManager.h"
#import "PXP_Internal.h"

@interface PXPWeakObjectContainer : NSObject

- (instancetype)init NS_UNAVAILABLE;
@property (nonatomic, readonly, weak) id object;

@end

@implementation PXPWeakObjectContainer

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}
@end

@implementation UIImageView (PXPExtensions)

@dynamic pxp_transfrom;
@dynamic pxp_downloadTask;

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

- (void)setPxp_downloadTask:(NSURLSessionDataTask *)downloadTask {
    NSString* key = NSStringFromSelector(@selector(pxp_downloadTask));
    PXPWeakObjectContainer *container = [[PXPWeakObjectContainer alloc] initWithObject:downloadTask];
    objc_setAssociatedObject(self, (__bridge const void *)(key), container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDataTask*)pxp_downloadTask {
    NSString* key = NSStringFromSelector(@selector(pxp_downloadTask));
    PXPWeakObjectContainer *container = objc_getAssociatedObject(self, (__bridge const void *)(key));
    return container.object;
}

- (void)pxp_requestImageForPath:(NSString*)path {
    [self.pxp_downloadTask cancel];
    self.image = nil;
    self.pxp_transfrom.fitSize = [self smallestSize];
    self.pxp_downloadTask = [[PXP sharedSDK].imageTaskManager imageDownloadTaskWithPath:path transform:self.pxp_transfrom completion:^(UIImage *responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = responseObject;
        });
    }];
}

- (void)pxp_requestImage:(NSURL*)url {
    [self.pxp_downloadTask cancel];
    self.image = nil;
    self.pxp_transfrom.fitSize = [self smallestSize];
    self.pxp_downloadTask = [[PXP sharedSDK].imageTaskManager imageDownloadTaskWithUrl:url transform:self.pxp_transfrom completion:^(UIImage *responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = responseObject;
        });
    }];
}

- (CGSize)smallestSize {
    CGRect rect = self.bounds;
    CGRect superRect = CGRectZero;
    UIView* currentView = self.superview;
    while (currentView != nil) {
        if (currentView != nil) {
            superRect = currentView.frame;
            currentView = currentView.superview;
        }
    }
    if (CGRectEqualToRect(CGRectZero, superRect)) {
        return rect.size;
    } else {
        return superRect.size;
    }
}

@end
