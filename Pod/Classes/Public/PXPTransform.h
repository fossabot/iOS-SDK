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

@interface PXPTransform : NSObject

@property (nonatomic, assign) PXPTransformQuality imageQuality;
@property (nonatomic, assign) PXPTransformFormat imageFormat;
@property (nonatomic, assign) CGSize fitSize;
@property (nonatomic, readonly, assign) CGSize fitSizeInPixels;

@end

@interface PXPTransform (PXPStringRepresentation)

- (NSString *)qualityString;
- (NSString *)formatString;
- (NSString *)sizeString;

@end
