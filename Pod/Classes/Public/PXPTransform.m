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
#import "PXP.h"
#import "PXP_Internal.h"
#import "PXPAccountInfo.h"

NS_ASSUME_NONNULL_BEGIN

static NSString* const kPXPDefaultFormat = @"def";
static NSString* const kPXPWebPFormat = @"webp";

@implementation PXPTransform

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _format = PXPTransformFormatDefault;
        _transformMode = PXPTransformModeFit;
    }
    return self;
}

- (instancetype)initWithOriginUrl:(NSString*)url {
    self = [self init];
    if (self != nil) {
        _originUrl = url;
        _format = PXPTransformFormatDefault;
    }
    return self;
}

- (NSString*)transfromFormatString {
    NSString* result = [PXPTransform transfromFormatDictionary][@(self.format)];
    if (result == nil) {
        result = kPXPDefaultFormat;
    }
    return result;
}

- (NSString* _Nullable)contentUrl {
    NSString* result = self.originUrl;
    NSMutableArray* components = [NSMutableArray new];
    NSString* cdnUrl = [PXPTransform cdnUrl];
    do {
        if (cdnUrl != nil) {
            [components addObject:cdnUrl];
        } else break;
        NSString* urlType = [PXPTransform originUrlType:self.originUrl];
        [components addObject:urlType];
        [components addObject:[self transfromFormatString]];
        NSMutableArray* transfromComponents = [NSMutableArray new];

        NSUInteger widthValue = (self.width != nil ? self.width.unsignedIntegerValue * [UIScreen mainScreen].scale : 0);
        NSUInteger heightValue = (self.height != nil ? self.height.unsignedIntegerValue * [UIScreen mainScreen].scale : 0);
        NSString* height = [NSString stringWithFormat:@"h_%lu", (unsigned long)heightValue];
        NSString* width = [NSString stringWithFormat:@"w_%lu", (unsigned long)widthValue];

        switch (self.transformMode) {
            case PXPTransformModeFill: {
                SAFE_ADD_OBJECT(transfromComponents, width);
                SAFE_ADD_OBJECT(transfromComponents, height);
                break;
            }
            default: {
                if (widthValue <= heightValue && widthValue > 0) {
                    SAFE_ADD_OBJECT(transfromComponents, width);
                } else if (heightValue > 0) {
                    SAFE_ADD_OBJECT(transfromComponents, height);
                } else {
                    SAFE_ADD_OBJECT(transfromComponents, width);
                    SAFE_ADD_OBJECT(transfromComponents, height);
                }
                break;
            }
        }
        if (self.quality != nil) {
            NSString* quality = [NSString stringWithFormat:@"q_%lu", (unsigned long)self.quality.unsignedIntegerValue];
            [transfromComponents addObject:quality];
        }
        NSString* transfrom = [transfromComponents componentsJoinedByString:@","];
        [components addObject:transfrom];
        [components addObject:self.originUrl];
        result = [components componentsJoinedByString:@"/"];
    } while (NO);
    PXPLog(@"URL: %@", result);
    return result;
}

#pragma mark - Class Methods

+ (NSString*)originUrlType:(NSString*)originUrl {
    if ([originUrl hasPrefix:@"http://"] || [originUrl hasPrefix:@"https://"]) {
        return @"remote";
    } else {
        return @"local";
    }
}

+ (NSString * _Nullable)cdnUrl {
    NSString* result =  [[PXP sharedSDK].accountInfo.cdnUrl copy];
    return result;
}

+ (NSDictionary<NSNumber*, NSString*>*)transfromFormatDictionary {
    static NSDictionary *_sPXPFormats = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sPXPFormats = @{ @(PXPTransformFormatDefault) : kPXPDefaultFormat,
                          @(PXPTransformFormatWebP) : kPXPWebPFormat};
    });
    return _sPXPFormats;
}

@end

NS_ASSUME_NONNULL_END
