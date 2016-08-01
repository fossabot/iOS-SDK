//
//  PXPTransform.m
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import "PXPTransform.h"
#import "PXPDefines.h"
#import "PXPNetworkTechnologies.h"
#import "PXPNetInfo.h"
#import "PXPNetworkMonitor.h"
#import "UIImageView+PXPExtensions.h"
#import "PXPDataMonitor.h"

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

NSString* PXPTransformQualityForSpeed(PXPDataSpeed dataSpeed) {
    static NSDictionary *_sPXPQualities = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sPXPQualities = @{
                           @(PXPDataSpeedExtraLow) : @"50",
                           @(PXPDataSpeedLow) : @"50",
                           @(PXPDataSpeedMedium) : @"80",
                           @(PXPDataSpeedHigh) : @"80",
                           @(PXPDataSpeedExtraHigh) : @"80",
                           @(PXPDataSpeedUndefined) : @"80",
                           @(PXPDataSpeedIdle) : @"80"
                           };
    });
    NSString* result = _sPXPQualities[@(dataSpeed)];
    if (result == nil) {
        result = @"80";
    };
    return result;
}

NSString* PXPTransformQualityForNetInfo(PXPNetInfo* netInfo) {
    static NSDictionary *sPXPQualities = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPXPQualities = @{PXPNetworkUnknown : @"80",
                          PXPNetworkWiFi : @"80",
                          PXPNetworkCDMAEVDORevB : @"80",
                          PXPNetworkCDMAEVDORevA : @"80",
                          PXPNetworkCDMAEVDORev0 : @"80",
                          PXPNetworkCDMA1x : @"70",
                          PXPNetworkWCDMA : @"50",
                          PXPNetworkHSUPA : @"50",
                          PXPNetworkHSDPA : @"50",
                          PXPNetworkeHRPD : @"50",
                          PXPNetworkGPRS : @"30",
                          PXPNetworkEdge : @"30",
                          PXPNetworkLTE : @"80"};
    });
    NSString* result = sPXPQualities[netInfo.technology];
    if (result == nil) {
        result = @"50";
    };
    return result;
}

static const NSInteger PXPImageSizes[] = { 50, 100, 160, 192, 310, 384, 512, 640, 768, 1024, 1536, 2048 };
static const NSInteger PXPImageSizesLength = 12;

@implementation PXPTransform

@synthesize fitSize = _fitSize;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithImageView:(UIImageView*)view {
    self = [self init];
    if (self != nil) {
        _imageView = view;
        _imageView.pxp_transform = self;
        _fitSizeStyle = PXPTransformFitSizeStyleAutomatic;
    }
    return self;
}

- (void)setImageView:(UIImageView *)view {
    if (_imageView != view) {
        _imageView = view;
        _imageView.pxp_transform = self;
    }
}

- (CGSize)fitSizeInPixels {
    CGFloat scale = [UIScreen mainScreen].scale;
    NSUInteger width = lround(self.fitSize.width * scale);
    NSUInteger height = lround(self.fitSize.height * scale);
    CGSize size = {width, height};
    return size;
}

- (CGSize)fitSize {
    if (_fitSizeStyle == PXPTransformFitSizeStyleAutomatic && self.imageView != nil) {
        return self.imageView.bounds.size;
    } else {
        return _fitSize;
    }
}

- (void)setFitSize:(CGSize)fitSize {
    if (!CGSizeEqualToSize(_fitSize, fitSize)) {
        _fitSizeStyle = PXPTransformFitSizeStyleManual;
        _fitSize = fitSize;
    }
}

@end

@implementation PXPTransform (PXPStringRepresentation)

+ (NSInteger)closestPXPSizeToSize:(CGSize)size {
    NSInteger value = PXPFirstClosest(PXPImageSizes, PXPImageSizesLength, size.width);
    return value;
}

- (NSString *)qualityString {
    NSString *quality = @"80";
    if (self.imageQuality == PXPTransformQualityAutomatic) {
//        PXPNetInfo* netInfo = [PXPNetworkMonitor sharedMonitor].currentNetworkTechnology;
//        quality = PXPTransformQualityForNetInfo(netInfo);
        quality = PXPTransformQualityForSpeed([PXPDataMonitor sharedMonitor].speedType);
    }
    return quality;
}

- (NSString *)formatString {
    NSString *extension = @"webp";
    if (self.imageFormat == PXPTransformFormatAutomatic) {
        extension = @"webp";
    }
    return extension;
}

- (NSString *)sizeString {
    NSString *size = @"640";
    if (!CGSizeEqualToSize(self.fitSize, CGSizeZero)) {
        size = [NSString stringWithFormat:@"%ld", (long)[PXPTransform closestPXPSizeToSize:self.fitSizeInPixels]];
    }
    return size;
}

@end
