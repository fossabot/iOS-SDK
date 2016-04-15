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
    PXPTransformQualityAutomatic,
    PXPTransformQualityDefault
} PXPTransformQuality;

typedef enum : NSInteger {
    PXPTransformFormatAutomatic
} PXPTransformFormat;

typedef enum : NSInteger {
    PXPTransformFitSizeStyleManual,
    PXPTransformFitSizeStyleAutomatic
} PXPTransformFitSizeStyle;

NS_ASSUME_NONNULL_BEGIN

@interface PXPTransform : NSObject

- (instancetype)init;
- (instancetype)initWithImageView:(UIImageView* _Nullable)view;

@property (nonatomic, weak, nullable) UIImageView* imageView;
@property (nonatomic, assign) PXPTransformQuality imageQuality;
@property (nonatomic, assign) PXPTransformFormat imageFormat;
@property (nonatomic, assign) PXPTransformFitSizeStyle fitSizeStyle;
@property (nonatomic, assign) CGSize fitSize;
@property (nonatomic, readonly, assign) CGSize fitSizeInPixels;

@end

@interface PXPTransform (PXPStringRepresentation)

- (NSString *)qualityString;
- (NSString *)formatString;
- (NSString *)sizeString;

@end

NS_ASSUME_NONNULL_END
