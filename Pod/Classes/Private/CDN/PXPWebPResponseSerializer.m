//
//  PXPWebPResponseSerializer.m
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPWebPResponseSerializer.h"
#import <UIImage+PXP_WebP.h>

@implementation PXPWebPResponseSerializer

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error {
    UIImage* image = [UIImage pxp_imageWithWebPData:data];
    return image;
}

@end
