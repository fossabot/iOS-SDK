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
        quality = @"90";
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

@interface NSURL (PXPImageTransform)

- (NSString *)pxp_urlStringForTransform:( PXPTransform* _Nonnull )transform;
- (NSString *)pxp_imagePath;

@end

@implementation NSURL (PXPImageTransform)

- (NSString *)pxp_urlStringForTransform:( PXPTransform* _Nonnull )transform {

    NSString* host = [PXP sharedSDK].accountInfo.cdnUrl;
    assert(host != nil);

    NSString* name = [[self.path lastPathComponent] stringByDeletingPathExtension];
    assert(name != nil);

    NSString *url = nil;
    NSString *path = nil;
    NSString *fileName = nil;
    NSString *extension = [transform formatString];
    NSString *quality = [transform qualityString];
    NSString *size = [transform sizeString];

    NSMutableArray *fileNameArray = [NSMutableArray new];
    SAFE_ADD_OBJECT(fileNameArray, size);
    SAFE_ADD_OBJECT(fileNameArray, quality);
    SAFE_ADD_OBJECT(fileNameArray, extension);
    fileName = [fileNameArray componentsJoinedByString:@"_"];

    NSMutableArray *pathArray = [NSMutableArray new];
    SAFE_ADD_OBJECT(pathArray, name);
    SAFE_ADD_OBJECT(pathArray, @".resource");
    path = [pathArray componentsJoinedByString:@""];

    NSMutableArray *urlArray = [NSMutableArray new];
    SAFE_ADD_OBJECT(urlArray, host);
    SAFE_ADD_OBJECT(urlArray, path);
    url = [urlArray componentsJoinedByString:@"/"];
    return url;
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
    NSString* urlString = [url pxp_urlStringForTransform:transform];

    PXPImageRequestCompletionBlock block = ^(id responseObject, NSError* error) {
        if (error == nil) {
            completionBlock(responseObject, nil);
        }
        else {
            [self imageTaskWithUrl:url completion:completionBlock];
            [self.sdkRequestWrapper updateImageWithWidth:transform.sizeString quality:transform.qualityString path:url.pxp_imagePath successBlock:^(id responseObject) {
                NSLog(@"OK: %@", responseObject);
            } failtureBlock:^(NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    };
    //NSURLSessionTask* task =
    [self imageTaskWithUrl:[NSURL URLWithString:urlString] completion:block];
    return nil;
}

- (void)imageTaskWithUrl:(NSURL*)url completion:(PXPImageRequestCompletionBlock)completionBlock {
    [self.imageRequestWrapper imageTaskForUrl:url completion:completionBlock];
}

@end
