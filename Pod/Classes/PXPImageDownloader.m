//
//  PXPImageDownloader.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPImageDownloader.h"
#import "PXPRequestWrapper.h"
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

@interface NSURL (ImageTransform)

- (NSString *)urlStringForTransform:( PXPTransform* _Nonnull )transform;

@end

@implementation NSURL (ImageTransform)

+ (NSInteger)closestPXPSizeToSize:(PXSize)size {
    NSInteger value = PXPFirstClosest(sizes, 9, size.width);
    return value;
}

- (NSString *)urlStringForTransform:( PXPTransform* _Nonnull )transform {

    NSString* host = [PXP sharedSDK].accountInfo.cdnUrl;
    assert(host != nil);

    NSString* name = [[self.path lastPathComponent] stringByDeletingPathExtension];
    assert(name != nil);

    NSString *url = nil;
    NSString *path = nil;
    NSString *fileName = nil;
    NSString *extension = nil;
    NSString *quality = nil;
    NSString *size = nil;
    if (transform.imageFormat == PXPTransformFormatAutomatic) {
        extension = @"webp";
    }
    if (transform.imageQuality == PXPTransformQualityAutomatic) {
        quality = @"90";
    }
    if (!CGSizeEqualToSize(transform.fitSize, CGSizeZero)) {
        size = [NSString stringWithFormat:@"%ld", [NSURL closestPXPSizeToSize:transform.fitSizeInPixels]];
    }
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

@end

@interface PXPImageDownloader ()

@property (nonatomic, strong) PXPImageRequestWrapper* imageRequestWrapper;
@property (nonatomic, strong) PXPRequestWrapper* sdkRequestWrapper;

@end

@implementation PXPImageDownloader

+ (instancetype)sharedDownloader {
    static PXPImageDownloader *_sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDownloader = [PXPImageDownloader new];
    });

    return _sharedDownloader;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _imageRequestWrapper = [PXPImageRequestWrapper new];
        _sdkRequestWrapper = [PXPRequestWrapper sharedWrapper];
    }
    return self;
}

- (NSURLSessionDataTask*)imageTaskWithUrl:(NSURL*)url transform:(PXPTransform*)transform completion:(PXPImageRequestCompletionBlock)completionBlock {
    NSString* urlString = [url urlStringForTransform:transform];

    PXPImageRequestCompletionBlock block = ^(id responseObject, NSError* error) {
        if (error == nil) {
            completionBlock(responseObject, nil);
        }
        else {
            [self imageTaskWithUrl:url completion:completionBlock];
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
