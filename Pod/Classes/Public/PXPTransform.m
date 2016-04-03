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

@implementation PXPTransform

- (CGSize)fitSizeInPixels {
    CGFloat scale = [UIScreen mainScreen].scale;
    NSUInteger width = lround(self.fitSize.width * scale);
    NSUInteger height = lround(self.fitSize.height * scale);
    CGSize size = {width, height};
    return size;
}

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
