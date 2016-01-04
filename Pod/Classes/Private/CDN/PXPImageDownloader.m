//
//  PXPImageDownloader.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPImageDownloader.h"
#import "PXPSDKRequestWrapper.h"
#import "PXPTransform.h"
#import "PXPImageRequestWrapper.h"
#import "PXP.h"
#import "PXP_Internal.h"
#import "PXPAccountInfo.h"
#import "PXPNetworkMonitor.h"
#import "PXPNetInfo.h"
#import "PXPNetworkTechnologies.h"

#define SAFE_ADD_OBJECT(mutableArray, value) if (nil != value) [mutableArray addObject:value]

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

static const NSInteger sizes[] = { 160, 192, 310, 384, 512, 640, 768, 1024, 2048};

@interface PXPTransform (PXPStringRepresentation)

- (NSString *)qualityString;
- (NSString *)formatString;
- (NSString *)sizeString;

@end

@implementation PXPTransform (PXPStringRepresentation)

+ (NSInteger)closestPXPSizeToSize:(PXSize)size {
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

@interface NSString (PXPImageTransform)

+ (NSString *)pxp_cdnUrl;
- (NSString *)pxp_imagePath;
- (NSString *)pxp_urlStringForTransform:( PXPTransform* _Nullable )transform;

@end

@implementation NSString (PXPImageTransform)

+ (NSString *)pxp_cdnUrl {
    NSString* scheme = @"http://";
    NSString* host = [PXP sharedSDK].accountInfo.cdnUrl;
    return [NSString stringWithFormat:@"%@%@", scheme, host];
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

    NSString *cdnUrl = [NSString pxp_cdnUrl];
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
    SAFE_ADD_OBJECT(pathArray, name);
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

@interface NSURL (PXPUrl)

- (BOOL)pxp_isCDNUrl;

@end

@implementation NSURL (PXPUrl)

- (BOOL)pxp_isCDNUrl {
    return ([self.host isEqualToString:[NSString pxp_cdnUrl]]);
}

@end

@interface PXPImageDownloader ()

@property (nonatomic, strong) PXPImageRequestWrapper* imageRequestWrapper;
@property (nonatomic, strong) PXPSDKRequestWrapper* sdkRequestWrapper;

@end

@implementation PXPImageDownloader

- (instancetype)initWithSDKRequestWrapper:(PXPSDKRequestWrapper*)wrapper
{
    self = [super init];
    if (self != nil) {
        _imageRequestWrapper = [PXPImageRequestWrapper new];
        _sdkRequestWrapper = wrapper;
    }
    return self;
}

- (NSURLSessionDataTask*)imageTaskWithUrl:(NSURL*)url transform:(PXPTransform*)transform completion:(PXPImageRequestCompletionBlock)completionBlock {
    if ([url pxp_isCDNUrl]) {
        return [self imageTaskWithPath:url.path.pxp_imagePath transform:transform completion:completionBlock];
    }
    else {
        return [self imageTaskWithUrl:url completion:completionBlock];
    }
    return nil;
}

- (NSURLSessionDataTask*)imageTaskWithPath:(NSString*)path transform:(PXPTransform*)transform completion:(PXPImageRequestCompletionBlock)completionBlock {
    NSString* urlString = [path pxp_urlStringForTransform:transform];

    PXPImageRequestCompletionBlock block = ^(id responseObject, NSError* error) {
        if (error == nil) {
            completionBlock(responseObject, nil);
        }
        else {
            NSURL* url = [NSURL URLWithString:[path pxp_urlStringForTransform:nil]];
            [self imageTaskWithUrl:url completion:completionBlock];
            [self.sdkRequestWrapper updateImageWithWidth:transform.sizeString quality:transform.qualityString path:url.path.pxp_imagePath successBlock:^(id responseObject) {
                NSLog(@"OK: %@", responseObject);
            } failtureBlock:^(NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    };
    [self imageTaskWithUrl:[NSURL URLWithString:urlString] completion:block];
    return nil;
}

- (NSURLSessionDataTask*)imageTaskWithUrl:(NSURL*)url completion:(PXPImageRequestCompletionBlock)completionBlock {
    return [self.imageRequestWrapper imageTaskForUrl:url completion:completionBlock];
}

@end
