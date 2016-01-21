//
//  UIImage+WebP.h
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libwebp/webp/decode.h>
#import <libwebp/webp/encode.h>

@interface UIImage (PXP_WebP)

+ (UIImage*)pxp_imageWithWebPData:(NSData*)imgData;

+ (UIImage*)pxp_imageWithWebP:(NSString*)filePath;

+ (NSData*)pxp_imageToWebP:(UIImage*)image quality:(CGFloat)quality;

+ (void)pxp_imageToWebP:(UIImage*)image
                quality:(CGFloat)quality
                  alpha:(CGFloat)alpha
                 preset:(WebPPreset)preset
        completionBlock:(void (^)(NSData* result))completionBlock
           failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)pxp_imageToWebP:(UIImage*)image
                quality:(CGFloat)quality
                  alpha:(CGFloat)alpha
                 preset:(WebPPreset)preset
            configBlock:(void (^)(WebPConfig* config))configBlock
        completionBlock:(void (^)(NSData* result))completionBlock
           failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)pxp_imageWithWebP:(NSString*)filePath
          completionBlock:(void (^)(UIImage* result))completionBlock
             failureBlock:(void (^)(NSError* error))failureBlock;

- (UIImage*)pxp_imageByApplyingAlpha:(CGFloat)alpha;

@end
