//
//  PXPImageCache.m
//  Pods
//
//  Created by Dmitry Osipa on 11/1/16.
//
//

#import "PXPImageCache.h"
#import "PXPTransform.h"

@interface PXPTransform (PXPInternal)

+ (NSString * _Nullable)cdnUrl;

@end

static inline NSString * PXPImageCacheKeyFromURLRequest(NSURLRequest *request) {
    NSString* result = [[request URL] absoluteString];
    NSString* cdnUrl = [PXPTransform cdnUrl];
    if (cdnUrl.length > 0 && [result hasPrefix:cdnUrl]) {

        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@",{0,1}q_([0-9]{1,3})"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSRange range = [regex rangeOfFirstMatchInString:result options:0 range:NSMakeRange(0, result.length)];
        result = [result stringByReplacingCharactersInRange:range withString:@""];
    }
    return result;
}

@interface PXPImageCache ()

@end

@implementation PXPImageCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.totalCostLimit = 10000000;
        self.countLimit = 100;

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [self removeAllObjects];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    return [self objectForKey:PXPImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    if (image && request) {
        [self setObject:image forKey:PXPImageCacheKeyFromURLRequest(request) cost:image.size.width * image.size.height];
    }
}

@end
