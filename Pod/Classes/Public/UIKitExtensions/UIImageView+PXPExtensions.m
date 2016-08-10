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
#import "PXPImageTask.h"

@interface PXPWeakObjectContainer : NSObject

- (instancetype)init NS_UNAVAILABLE;
@property (atomic, readonly, weak) id object;

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

static NSString* const kPXPTransformKey = @"pxp_transformKey";
static NSString* const kPXPDownloadTaskKey = @"pxp_downloadTaskKey";

@implementation UIImageView (PXPExtensions)

//@dynamic pxp_transform;
//@dynamic pxp_downloadTask;

#pragma mark - Public Interface

- (void)pxp_requestImageForPath:(NSString*)path completion:(PXPImageRequestCompletionBlock _Nullable)completion {

    [self cancelLoad];
    self.image = nil;
    if (self.pxp_transform.fitSizeStyle == PXPTransformFitSizeStyleAutomatic) {
        self.pxp_transform.fitSize = [self smallestSize];
    }
    self.pxp_downloadTaskIdentifier = [[PXP sharedSDK].imageTaskManager imageDownloadTaskWithPath:path
                                                                                        transform:self.pxp_transform
                                                                                          headers:nil
                                                                                   uploadProgress:nil
                                                                                 downloadProgress:nil
                                                                                       completion:^(NSURL * _Nullable url, UIImage * _Nullable responseObject, NSError * _Nullable error) {
                                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                                               if (completion != NULL) {
                                                                                                   
                                                                                                   completion(url, responseObject, error);
                                                                                               } else {
                                                                                                   self.image = responseObject;
                                                                                               }
                                                                                           });
                                                                                       }];
}

- (void)pxp_requestImage:(NSURL *)url {
    [self pxp_requestImage:url headers:nil completion:nil];
}

- (void)pxp_requestImage:(NSURL*)url
                 headers:(NSDictionary * _Nullable )headers
              completion:(PXPImageRequestCompletionBlock _Nullable)completion {

    [self cancelLoad];
    self.image = nil;
    if (self.pxp_transform.fitSizeStyle == PXPTransformFitSizeStyleAutomatic) {
        self.pxp_transform.fitSize = [self smallestSize];
    }
    self.pxp_downloadTaskIdentifier = [[PXP sharedSDK].imageTaskManager imageDownloadTaskWithUrl:url transform:self.pxp_transform headers:headers uploadProgress:nil downloadProgress:nil completion:^(NSURL * _Nullable url, UIImage * _Nullable responseObject, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion != NULL) {

                completion(url, responseObject, error);
            } else {
                self.image = responseObject;
            }
        });
    }];
}

- (void)cancelLoad {
    [[PXP sharedSDK].imageTaskManager cancelTaskWithIdentifier:self.pxp_downloadTaskIdentifier];
    self.pxp_downloadTaskIdentifier = nil;
}

#pragma mark - Private Interface

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

- (void)setPxp_transform:(PXPTransform * __nullable)transform {
    objc_setAssociatedObject(self, (__bridge const void *)(kPXPTransformKey), transform, OBJC_ASSOCIATION_RETAIN);
}

- (PXPTransform*)pxp_transform {
    PXPTransform* transform = objc_getAssociatedObject(self, (__bridge const void *)(kPXPTransformKey));
    if (transform == nil) {
        transform = [[PXPTransform alloc] initWithImageView:self];
        objc_setAssociatedObject(self, (__bridge const void *)(kPXPTransformKey), transform, OBJC_ASSOCIATION_RETAIN);
    }
    return transform;
}

- (void)setPxp_downloadTaskIdentifier:(NSString * __nullable)downloadTaskIdentifier {
    PXPWeakObjectContainer* container = [[PXPWeakObjectContainer alloc] initWithObject:downloadTaskIdentifier];
    objc_setAssociatedObject(self, (__bridge const void *)(kPXPDownloadTaskKey), container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)pxp_downloadTaskIdentifier {

    PXPWeakObjectContainer* container = objc_getAssociatedObject(self, (__bridge const void *)(kPXPDownloadTaskKey));
    return container.object;
}

@end
