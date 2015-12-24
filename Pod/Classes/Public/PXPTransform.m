//
//  PXPTransform.m
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import "PXPTransform.h"

@implementation PXPTransform

- (PXSize)fitSizeInPixels {
    CGFloat scale = [UIScreen mainScreen].scale;
    NSUInteger width = lround(self.fitSize.width * scale);
    NSUInteger height = lround(self.fitSize.height * scale);
    PXSize size = {width, height};
    return size;
}

@end
