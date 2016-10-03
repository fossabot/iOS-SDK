//
//  UIImage+WebP.m
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import "UIImage+PXP_WebP.h"
#import <WebP/decode.h>

@implementation UIImage (PXP_WebP)

#pragma mark - Synchronous methods

+ (UIImage *)pxp_imageWithWebPData:(NSData *)imgData error:(NSError **)error
{
    NSParameterAssert(imgData != nil);
    UIImage *image = nil;

    // `WebPGetInfo` weill return image width and height
    int width = 0, height = 0;
    if(!WebPGetInfo([imgData bytes], [imgData length], &width, &height)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Header formatting error." forKey:NSLocalizedDescriptionKey];
        if(error != NULL) {
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        }
    } else {
        const struct { int width, height; } targetContextSize = { width, height};

        size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);

        void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;

        CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);

        UIGraphicsPushContext(targetContext);

        CGColorSpaceRelease(colorSpace);

        if (WebPDecodeBGRAInto(imgData.bytes, imgData.length, targetMemory, targetBytesPerRow * targetContextSize.height, (int)targetBytesPerRow) == NULL) {
            NSLog(@"error decoding webp");
        }

        for (int y = 0; y < targetContextSize.height; y++) {
            for (int x = 0; x < targetContextSize.width; x++) {
                uint32_t *color = ((uint32_t *)&targetMemory[y * targetBytesPerRow + x * 4]);

                uint32_t a = (*color >> 24) & 0xff;
                uint32_t r = ((*color >> 16) & 0xff) * a;
                uint32_t g = ((*color >> 8) & 0xff) * a;
                uint32_t b = (*color & 0xff) * a;

                r = (r + 1 + (r >> 8)) >> 8;
                g = (g + 1 + (g >> 8)) >> 8;
                b = (b + 1 + (b >> 8)) >> 8;

                *color = (a << 24) | (r << 16) | (g << 8) | b;
            }

            for (size_t i = y * targetBytesPerRow + targetContextSize.width * 4; i < (targetBytesPerRow >> 2); i++) {
                *((uint32_t *)&targetMemory[i]) = 0;
            }
        }
        UIGraphicsPopContext();

        CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
        image = [[UIImage alloc] initWithCGImage:bitmapImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        CGImageRelease(bitmapImage);

        CGContextRelease(targetContext);
        free(targetMemory);
    }
    return image;
}

#pragma mark - Error statuses

+ (NSString *)statusForVP8Code:(VP8StatusCode)code
{
    NSString *errorString;
    switch (code) {
        case VP8_STATUS_OUT_OF_MEMORY:
            errorString = @"OUT_OF_MEMORY";
            break;
        case VP8_STATUS_INVALID_PARAM:
            errorString = @"INVALID_PARAM";
            break;
        case VP8_STATUS_BITSTREAM_ERROR:
            errorString = @"BITSTREAM_ERROR";
            break;
        case VP8_STATUS_UNSUPPORTED_FEATURE:
            errorString = @"UNSUPPORTED_FEATURE";
            break;
        case VP8_STATUS_SUSPENDED:
            errorString = @"SUSPENDED";
            break;
        case VP8_STATUS_USER_ABORT:
            errorString = @"USER_ABORT";
            break;
        case VP8_STATUS_NOT_ENOUGH_DATA:
            errorString = @"NOT_ENOUGH_DATA";
            break;
        default:
            errorString = @"UNEXPECTED_ERROR";
            break;
    }
    return errorString;
}
@end
