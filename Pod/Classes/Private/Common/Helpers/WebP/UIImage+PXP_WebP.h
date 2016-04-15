//
//  UIImage+WebP.h
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebP/encode.h>

@interface UIImage (PXP_WebP)

+ (UIImage *)pxp_imageWithWebPData:(NSData *)imgData error:(NSError **)error;

@end
