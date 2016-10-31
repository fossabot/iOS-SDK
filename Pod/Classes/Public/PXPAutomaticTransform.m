//
//  PXPAutomaticTransform.m
//  Pods
//
//  Created by Dmitry Osipa on 9/12/16.
//
//

#import "PXPAutomaticTransform.h"
#import "PXPDataMonitor.h"

@implementation PXPAutomaticTransform

- (instancetype)initWithImageView:(UIImageView*)contextView originUrl:(NSString*)url; {
    self = [super initWithOriginUrl:url];
    if (self != nil) {
        _contextView = contextView;
    }
    return self;
}

- (CGSize)smallestSize {
    CGRect rect = self.contextView.bounds;
    CGRect superRect = CGRectZero;
    UIView* currentView = self.contextView.superview;
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

- (NSNumber*)width {
    NSNumber* width = super.width;
    if (width == nil) {
        CGSize size = [self smallestSize];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            width = @([self smallestSize].width);
        }
    }
    return width;
}

- (NSNumber*)height {
    NSNumber* height = super.height;
    if (height == nil) {
        CGSize size = [self smallestSize];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            height = @([self smallestSize].height);
        }
    }
    return height;
}

- (NSNumber*)quality {
    NSNumber* quality = super.quality;
    if (quality == nil) {
        PXPDataMonitor* monitor = [PXPDataMonitor sharedMonitor];
        quality = [PXPAutomaticTransform qualityDictionary][@(monitor.speedType)];
    }
    return quality;
}

- (PXPTransformFormat)format {
    if (self.quality.integerValue == 100) {
        return PXPTransformFormatDefault;
    } else {
        return PXPTransformFormatWebP;
    };
}

+ (NSDictionary <NSNumber*, NSNumber*> *)qualityDictionary {
    static NSDictionary* sDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDict = @{ @(PXPDataSpeedUndefined) : @100,
                   @(PXPDataSpeedExtraLow) : @30,
                   @(PXPDataSpeedLow) : @50,
                   @(PXPDataSpeedMedium) : @80,
                   @(PXPDataSpeedHigh) : @80,
                   @(PXPDataSpeedExtraHigh) : @90,
                   @(PXPDataSpeedIdle) : @90,
                   @(PXPDataSpeedNone) : @90
                   };
    });
    return sDict;
}

@end
