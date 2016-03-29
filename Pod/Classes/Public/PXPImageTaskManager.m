//
//  PXPImageDownloader.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPImageTaskManager.h"
#import "PXPSDKRequestWrapper.h"
#import "PXPTransform.h"
#import "PXPImageRequestWrapper.h"
#import "PXP.h"
#import "PXP_Internal.h"
#import "PXPAccountInfo.h"
#import "PXPNetworkMonitor.h"
#import "PXPNetInfo.h"
#import "PXPNetworkTechnologies.h"
#import "PXPDefines.h"
#import "NSString+PXPSecurity.h"
#import "PXPDefines.h"
@import UIKit.UIGraphics;

#define SAFE_ADD_OBJECT(mutableArray, value) if (nil != value) [mutableArray addObject:value]

void PXPRunOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

typedef enum {
    PXPUrlTypeOther,
    PXPUrlTypePath,
    PXPUrlTypeCDN,
    PXPUrlTypeRemote
} PXPUrlType;

NSInteger PXPFirstClosest(const NSInteger *values, NSUInteger len, NSInteger value) {
    NSInteger dist = labs(values[0] - value);
    NSInteger closest;
    for (int i = 0; i < len; i++) {
        if (labs(values[i] - value) < dist) {
            dist = labs(values[i] - value);
            closest = i;
        }
    }
    return values[closest];
}


NSString* PXPTransformQualityForNetInfo(PXPNetInfo* netInfo) {
    static NSDictionary *sPXPQualities = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPXPQualities = @{PXPNetworkUnknown : @"75",
                          PXPNetworkWiFi : @"90",
                          PXPNetworkCDMAEVDORevB : @"80",
                          PXPNetworkCDMAEVDORevA : @"80",
                          PXPNetworkCDMAEVDORev0 : @"80",
                          PXPNetworkCDMA1x : @"70",
                          PXPNetworkWCDMA : @"80",
                          PXPNetworkHSUPA : @"80",
                          PXPNetworkHSDPA : @"80",
                          PXPNetworkeHRPD : @"80",
                          PXPNetworkGPRS : @"30",
                          PXPNetworkEdge : @"50",
                          PXPNetworkLTE : @"90"};
    });
    NSString* result = sPXPQualities[netInfo.technology];
    if (result == nil) {
        result = @"75";
    };
    return result;
}

static const NSInteger sizes[] = { 50, 100, 160, 192, 310, 384, 512, 640, 768, 1024, 2048 };

@interface PXPTransform (PXPStringRepresentation)

- (NSString *)qualityString;
- (NSString *)formatString;
- (NSString *)sizeString;

@end

@interface NSString (PXPImageTransform)

+ (NSString *)pxp_cdnUrl;
- (PXPUrlType)pxp_URLType;
- (NSString *)pxp_imagePath;
- (NSString *)pxp_urlStringForTransform:( PXPTransform* _Nullable )transform;

@end

@interface NSURL (PXPUrl)

- (PXPUrlType)pxp_URLType;
- (NSString*)pathAndQuery;

@end

@implementation PXPTransform (PXPStringRepresentation)

+ (NSInteger)closestPXPSizeToSize:(CGSize)size {
    NSInteger value = PXPFirstClosest(sizes, 9, size.width);
    return value;
}

- (NSString *)qualityString {
    NSString *quality = nil;
    if (self.imageQuality == PXPTransformQualityAutomatic) {
        PXPNetInfo* netInfo = [PXPNetworkMonitor sharedMonitor].currentNetworkTechnology;
        quality = PXPTransformQualityForNetInfo(netInfo);
    }
    return quality;
}

- (NSString *)formatString {
    NSString *extension = nil;
    if (self.imageFormat == PXPTransformFormatAutomatic) {
        extension = @"webp";
    }
    return extension;
}

- (NSString *)sizeString {
    NSString *size = nil;
    if (!CGSizeEqualToSize(self.fitSize, CGSizeZero)) {
        size = [NSString stringWithFormat:@"%ld", [PXPTransform closestPXPSizeToSize:self.fitSizeInPixels]];
    }
    return size;
}

@end

@implementation NSString (PXPImageTransform)

- (PXPUrlType)pxp_URLType {
    NSURL* url = [NSURL URLWithString:self];
    return ([url pxp_URLType]);
}

+ (NSString *)pxp_cdnUrl {
    NSString* scheme = @"http://";
    NSString* host = [PXP sharedSDK].accountInfo.cdnUrl;
    if (host.length == 0) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%@%@", scheme, host];
    }
}

+ (NSString *)pxp_cdnPathForUrl:(NSString *)remoteUrl {

    NSString* result = nil;
    PXPUrlType type = [remoteUrl pxp_URLType];
    switch (type) {
        case PXPUrlTypeCDN:
        case PXPUrlTypePath: {
            result = [NSString pxp_cdnUrl];
            break;
        }
        case PXPUrlTypeRemote: {
            NSString* host = [NSString pxp_cdnUrl];
            NSString* folder = @"remote.resources";
            result = [NSString stringWithFormat:@"%@/%@", host, folder];
            break;
        }
        default:
            break;
    }
    return result;
}

- (NSString *)pxp_imagePath {
    NSString* imagePath = nil;
    // URL ex.: http://cdn.example.com/app-id/image-path/../image.jpg
    NSMutableArray<NSString *> *pathComponents = [self.pathComponents mutableCopy];
    if (pathComponents.count > 1) {
        [pathComponents removeObjectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)]];
        imagePath = [pathComponents componentsJoinedByString:@"/"];
    }
    return imagePath;
}

- (NSString *)pxp_urlStringForTransform:( PXPTransform* _Nullable )transform {

    NSString *cdnUrl = [NSString pxp_cdnPathForUrl:self];
    NSString *name = [self lastPathComponent];
    assert(name != nil);

    NSString *url = nil;
    NSString *path = nil;
    NSString *fileName = nil;
    if (transform != nil) {
        NSString *extension = [transform formatString];
        NSString *quality = [transform qualityString];
        NSString *size = [transform sizeString];

        NSMutableArray *fileNameArray = [NSMutableArray new];
        SAFE_ADD_OBJECT(fileNameArray, size);
        SAFE_ADD_OBJECT(fileNameArray, quality);
        fileName = [fileNameArray componentsJoinedByString:@"_"];
        if (extension.length > 0) {
            fileName = [fileName stringByAppendingPathExtension:extension];
        }
    }

    NSMutableArray *pathArray = [NSMutableArray new];
    PXPUrlType type = [self pxp_URLType];
    if (type != PXPUrlTypeRemote) {
        SAFE_ADD_OBJECT(pathArray, name);
    } else {
        NSURL* url = [NSURL URLWithString:self];
        NSString* domain = url.host;
        NSMutableArray *md5Array = [NSMutableArray new];
        NSString* remoteUrlMD5 = [self MD5];
        NSString* firstPart = [remoteUrlMD5 substringToIndex:1];
        NSString* secondPart = [remoteUrlMD5 substringWithRange:NSMakeRange(1, 1)];
        NSString* thirdPart = [remoteUrlMD5 substringWithRange:NSMakeRange(2, 1)];
        NSString* lastPart = [remoteUrlMD5 substringFromIndex:3];
        SAFE_ADD_OBJECT(md5Array, domain);
        SAFE_ADD_OBJECT(md5Array, firstPart);
        SAFE_ADD_OBJECT(md5Array, secondPart);
        SAFE_ADD_OBJECT(md5Array, thirdPart);
        SAFE_ADD_OBJECT(md5Array, lastPart);
        NSString* md5Path = [md5Array componentsJoinedByString:@"/"];
        SAFE_ADD_OBJECT(pathArray, md5Path);
    }
    if (transform != nil) {
        SAFE_ADD_OBJECT(pathArray, @".pixpie.resource");
    }
    path = [pathArray componentsJoinedByString:@""];

    NSMutableArray *urlArray = [NSMutableArray new];
    SAFE_ADD_OBJECT(urlArray, cdnUrl);
    SAFE_ADD_OBJECT(urlArray, path);
    SAFE_ADD_OBJECT(urlArray, fileName);
    url = [urlArray componentsJoinedByString:@"/"];
    return url;
}

@end

@implementation NSURL (PXPUrl)

- (PXPUrlType)pxp_URLType {
    NSString* cdnUrl = [NSString pxp_cdnUrl];
    if (cdnUrl != nil && [self.absoluteString hasPrefix:cdnUrl]) {
        return PXPUrlTypeCDN;
    } else if (self.host == nil) {
        return PXPUrlTypePath;
    } else if ([self.scheme isEqualToString:@"http"] || [self.scheme isEqualToString:@"https"] ) {
        return PXPUrlTypeRemote;
    } else {
        return PXPUrlTypeOther;
    }
}

- (NSString*)pathAndQuery {
    NSString* path = self.path;
    NSString* query = self.query;
    NSMutableArray* array = [NSMutableArray new];
    SAFE_ADD_OBJECT(array, path);
    SAFE_ADD_OBJECT(array, query);
    return [array componentsJoinedByString:@""];
}

@end

@interface PXPImageTaskManager ()

@property (nonatomic, strong) PXPImageRequestWrapper* imageRequestWrapper;
@property (nonatomic, strong, readonly) PXPSDKRequestWrapper* sdkRequestWrapper;
@property (nonatomic, strong) NSOperationQueue* imageTransformQueue;

@end

@implementation PXPImageTaskManager

#pragma mark - Public Interface

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _imageRequestWrapper = [PXPImageRequestWrapper new];
        _imageTransformQueue = [NSOperationQueue new];
    }
    return self;
}

- (PXPSDKRequestWrapper *)sdkRequestWrapper {
    return [PXP sharedSDK].wrapper;
}

- (NSURLSessionDataTask*)imageDownloadTaskWithUrl:(NSURL*)url transform:(PXPTransform*)transform completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {
    PXPUrlType urlType = [url pxp_URLType];
    if ((urlType == PXPUrlTypePath || urlType== PXPUrlTypeCDN) && self.sdkRequestWrapper != nil) {
        return [self imageDownloadTaskWithPath:url.path.pxp_imagePath transform:transform completion:^(UIImage * _Nullable responseObject, NSError * _Nullable error) {
            PXPRunOnMainQueueWithoutDeadlocking(^{
                completionBlock(responseObject, error);
            });
        }];
    } else if (self.sdkRequestWrapper != nil) {
        return [self imageDownloadWithRemoteUrl:url transform:transform completion:^(UIImage * _Nullable responseObject, NSError * _Nullable error) {
            PXPRunOnMainQueueWithoutDeadlocking(^{
                completionBlock(responseObject, error);
            });
        }];
    } else {
        __weak typeof(self)weakSelf = self;
        return [self imageDownloadTaskWithUrl:url completion:^(UIImage * _Nullable responseObject, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (responseObject != nil) {
                [strongSelf applyTransfrom:transform toImage:responseObject completion:^(UIImage * _Nullable responseObject, NSError * _Nullable error) {
                    PXPRunOnMainQueueWithoutDeadlocking(^{
                        completionBlock(responseObject, error);
                    });
                }];
            } else {
                PXPRunOnMainQueueWithoutDeadlocking(^{
                    completionBlock(nil, error);
                });
            }
        }];
    }
    return nil;
}

- (NSURLSessionDataTask*)imageDownloadTaskWithPath:(NSString*)path
                                         transform:(PXPTransform*)transform completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    NSString* urlString = [path pxp_urlStringForTransform:transform];
    PXPImageDownloadRequestCompletionBlock block = ^(id responseObject, NSError* error) {
        if (error == nil) {
            completionBlock(responseObject, nil);
        } else {
            NSURL* url = [NSURL URLWithString:[path pxp_urlStringForTransform:nil]];
            [self imageDownloadTaskWithUrl:url completion:completionBlock];
            [self.sdkRequestWrapper updateImageWithWidth:transform.sizeString quality:transform.qualityString path:url.path.pxp_imagePath successBlock:^(id responseObject) {
                NSLog(@"OK: %@", responseObject);
            } failtureBlock:^(NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    };
    NSURLSessionDataTask* task = [self imageDownloadTaskWithUrl:[NSURL URLWithString:urlString] completion:block];
    return task;
}

- (NSURLSessionDataTask*)imageDownloadWithRemoteUrl:(NSURL*)url
                                          transform:(PXPTransform*)transform
                                         completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    NSString* urlString = [url.absoluteString pxp_urlStringForTransform:transform];
    PXPImageDownloadRequestCompletionBlock block = ^(id responseObject, NSError* error) {
        if (error == nil) {
            completionBlock(responseObject, error);
        } else {
            __weak typeof(self)weakSelf = self;
            [self imageDownloadTaskWithUrl:url completion:^(UIImage * _Nullable responseObject, NSError * _Nullable error) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (responseObject != nil) {
                    [strongSelf applyTransfrom:transform toImage:responseObject completion:completionBlock];
                } else {
                    completionBlock(nil, error);
                }
            }];
            [self.sdkRequestWrapper uploadImageTaskAtUrl:url.absoluteString width:transform.sizeString quality:transform.qualityString successBlock:^(id responseObject) {
                PXPLogInfo(@"Remote Image Upload OK: %@", responseObject);
            } failtureBlock:^(NSError *error) {
                PXPLogError(@"Remote Image Upload Error: %@", error);
            }];
        }
    };
    NSURLSessionDataTask* task = [self imageDownloadTaskWithUrl:[NSURL URLWithString:urlString] completion:block];
    return task;
}

#pragma mark - Private Interface

- (NSURLSessionDataTask*)imageDownloadTaskWithUrl:(NSURL*)url completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    return [self.imageRequestWrapper imageDownloadTaskForUrl:url completion:completionBlock];
}

- (void)applyTransfrom:(PXPTransform*)transform toImage:(UIImage*)image completion:(PXPImageDownloadRequestCompletionBlock)completionBlock {

    CGSize size = transform.fitSize;
    CGSize currentSize = image.size;
    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
        UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);

        float hfactor = currentSize.width / size.width;
        float vfactor = currentSize.height / size.height;

        float factor = fmax(hfactor, vfactor);
        float newWidth = currentSize.width / factor;
        float newHeight = currentSize.height / factor;
        
        [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        completionBlock(newImage, nil);
    }];
    [self.imageTransformQueue addOperation:operation];
}

@end
