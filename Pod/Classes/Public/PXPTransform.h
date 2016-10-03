//
//  PXPTransform.h
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef enum : NSInteger {
    PXPTransformFormatDefault = 0,
    PXPTransformFormatWebP
} PXPTransformFormat;

typedef enum {
    PXPTransformModeFill,
    PXPTransformModeFit
} PXPTransformMode;

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
- (NSString * _Nullable)contentUrl;

@end

NS_ASSUME_NONNULL_END
