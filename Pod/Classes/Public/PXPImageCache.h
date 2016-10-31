//
//  PXPImageCache.h
//  Pods
//
//  Created by Dmitry Osipa on 11/1/16.
//
//

#import <Foundation/Foundation.h>

@interface PXPImageCache : NSCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;

@end
