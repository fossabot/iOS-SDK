//
//  PXPWebPResponseSerializer.m
//  Pixpie
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXPWebPResponseSerializer.h"
#import <UIImage+PXP_WebP.h>

#import <objc/runtime.h>

@implementation PXPWebPImageResponseSerializer

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        NSMutableSet *contentTypes = [self.acceptableContentTypes mutableCopy];
        [contentTypes addObjectsFromArray:@[@"image/webp", @"application/octet-stream"]];
        self.acceptableContentTypes = contentTypes;
    }
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if ([response.MIMEType isEqualToString:@"image/webp"] ||
        [response.MIMEType isEqualToString:@"application/octet-stream"]) {
        
        return [UIImage pxp_imageWithWebPData:data error:error];
    }

    return [super responseObjectForResponse:response data:data error:error];
}

@end
