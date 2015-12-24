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

struct PXSize {
    NSInteger width;
    NSInteger height;
};
typedef struct PXSize PXSize;


@interface PXPTransform : NSObject

@property (nonatomic, assign) PXPTransformQuality imageQuality;
@property (nonatomic, assign) PXPTransformFormat imageFormat;
@property (nonatomic, assign) CGSize fitSize;
@property (nonatomic, readonly, assign) PXSize fitSizeInPixels;

@end
