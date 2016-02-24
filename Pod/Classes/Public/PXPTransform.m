//
//  PXPTransform.m
//  Pods
//
//  Created by Dmitry Osipa on 12/9/15.
//
//

#import "PXPTransform.h"
#import "PXPDefines.h"

@implementation PXPTransform

- (CGSize)fitSizeInPixels {
    CGFloat scale = [UIScreen mainScreen].scale;
    NSUInteger width = lround(self.fitSize.width * scale);
    NSUInteger height = lround(self.fitSize.height * scale);
    CGSize size = {width, height};
    return size;
}

@end
