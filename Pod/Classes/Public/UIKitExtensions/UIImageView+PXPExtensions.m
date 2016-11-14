//
//  UIImageView+PXPExtensions.m
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import "UIImageView+PXPExtensions.h"
#import "PXPAutomaticTransform.h"
#import <objc/runtime.h>
#import "PXP_Internal.h"
#import "AFHTTPSessionOperation.h"

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

#pragma mark - Public Interface


- (void)pxp_requestImage:(NSString *)url {
    [self pxp_requestImage:url headers:nil completion:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([responseObject isKindOfClass:[UIImage class]]) {
            self.image = (UIImage*)responseObject;
        }
    }];
}

- (void)pxp_requestImage:(NSString *)url
                 headers:(NSDictionary * _Nullable )headers
              completion:(PXPImageRequestCompletionBlock _Nullable)completion {

    [self pxp_cancelLoad];
    self.image = nil;
    self.pxp_transform.originUrl = url;
    NSString* finalUrl = self.pxp_transform.contentUrl;
    self.pxp_downloadTask = [[UIImageView pxp_sharedImageDownloader] imageDownloadTaskForUrl:finalUrl uploadProgress:nil downloadProgress:nil success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(task, responseObject, nil);
        });
    } failture:^(NSURLSessionTask * _Nonnull task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(task, nil, error);
        });
    }];
}

- (void)pxp_cancelLoad {
    [self.pxp_downloadTask cancel];
    self.pxp_downloadTask = nil;
}

#pragma mark - Private Interface

- (void)setPxp_transform:(PXPTransform * __nullable)transform {
    objc_setAssociatedObject(self, (__bridge const void *)(kPXPTransformKey), transform, OBJC_ASSOCIATION_RETAIN);
}

- (PXPTransform*)pxp_transform {
    PXPTransform* transform = objc_getAssociatedObject(self, (__bridge const void *)(kPXPTransformKey));
    if (transform == nil) {
        transform = [[PXPAutomaticTransform alloc] initWithImageView:self originUrl:nil];
        objc_setAssociatedObject(self, (__bridge const void *)(kPXPTransformKey), transform, OBJC_ASSOCIATION_RETAIN);
    }
    return transform;
}

- (void)setPxp_downloadTask:(AFHTTPSessionOperation * __nullable)downloadTaskIdentifier {
    PXPWeakObjectContainer* container = [[PXPWeakObjectContainer alloc] initWithObject:downloadTaskIdentifier];
    objc_setAssociatedObject(self, (__bridge const void *)(kPXPDownloadTaskKey), container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)pxp_downloadTask {

    PXPWeakObjectContainer* container = objc_getAssociatedObject(self, (__bridge const void *)(kPXPDownloadTaskKey));
    return container.object;
}

#pragma mark - Class Methods

+ (PXPImageRequestWrapper*)pxp_sharedImageDownloader {
    static PXPImageRequestWrapper* sWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sWrapper = [PXPImageRequestWrapper new];
    });
    return sWrapper;
}

@end
