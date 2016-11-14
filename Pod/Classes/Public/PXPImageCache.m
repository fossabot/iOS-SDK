//
//  PXPImageCache.m
//  Pixpie
//
//  Created by Dmitry Osipa on 11/1/16.
//
//

#import "PXPImageCache.h"
#import "PXPTransform.h"

@interface PXPTransform (PXPInternal)

+ (NSString * _Nullable)cdnUrl;

@end

static inline NSRegularExpression* PXPRegex() {
    static dispatch_once_t onceToken;
    static NSRegularExpression *regex = nil;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@",{0,1}q_([0-9]{1,3})"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
    });
    return regex;
}

static inline NSString * PXPImageCacheKeyFromURLRequest(NSURLRequest *request) {
    NSString* result = [[request URL] absoluteString];
    NSString* cdnUrl = [PXPTransform cdnUrl];
    if (cdnUrl.length > 0 && [result hasPrefix:cdnUrl]) {
        NSRange range = [PXPRegex() rangeOfFirstMatchInString:result options:0 range:NSMakeRange(0, result.length)];
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
        self.countLimit = 200;
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
    NSString* key = [PXPImageCache keyForRequest:request];
    return [self objectForKey:key];
}

- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    if (image && request) {
        NSString* key = [PXPImageCache keyForRequest:request];
        [self setObject:image forKey:key cost:0/*image.size.width * image.size.height*/];
    }
}

- (void)removeAllObjects {
    [super removeAllObjects];
    [[PXPImageCache requestKeyCache] removeAllObjects];
}

+ (NSString*)keyForRequest:(NSURLRequest*)request {
    NSCache* requestKeyCache = [PXPImageCache requestKeyCache];
    NSString* key = [requestKeyCache objectForKey:request];
    if (key.length == 0) {
        key = PXPImageCacheKeyFromURLRequest(request);
        [requestKeyCache setObject:key forKey:request];
    }
    return key;
}

+ (NSCache*)requestKeyCache {
    static dispatch_once_t onceToken;
    static NSCache* sRequestCache = nil;
    dispatch_once(&onceToken, ^{
        sRequestCache = [NSCache new];
        sRequestCache.countLimit = 500;
    });
    return sRequestCache;
}

@end
