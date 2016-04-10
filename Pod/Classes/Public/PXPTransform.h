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
    PXPTransformQualityAutomatic
} PXPTransformQuality;

typedef enum : NSInteger {
    PXPTransformFormatAutomatic
} PXPTransformFormat;

typedef enum : NSInteger {
    PXPTransformFitSizeStyleAutomatic,
    PXPTransformFitSizeStyleManual
} PXPTransformFitSizeStyle;

@interface PXPTransform : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImageView:(UIImageView*)view;

@property (nonatomic, weak) UIImageView* imageView;
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
