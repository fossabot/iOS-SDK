//
//  PXPTransform.h
//  Pixpie
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM(NSInteger, PXPTransformFormat) {
    PXPTransformFormatDefault = 0,
    PXPTransformFormatWebP
};

typedef NS_ENUM(unsigned int, PXPTransformMode) {
    PXPTransformModeFill,
    PXPTransformModeFit
};

NS_ASSUME_NONNULL_BEGIN

@interface PXPTransform : NSObject

@property (nonatomic, strong) NSString* originUrl;
@property (nonatomic, strong, nullable) NSNumber* width;
@property (nonatomic, strong, nullable) NSNumber* height;
@property (nonatomic, strong, nullable) NSNumber* quality;
@property (nonatomic, assign) PXPTransformFormat format;
@property (nonatomic, assign) PXPTransformMode transformMode;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithOriginUrl:(NSString*)url;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString * _Nullable contentUrl;

@end

NS_ASSUME_NONNULL_END
