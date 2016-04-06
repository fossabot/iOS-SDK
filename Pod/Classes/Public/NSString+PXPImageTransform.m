//
//  NSString+PXPImageTransform.m
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import "NSString+PXPImageTransform.h"
#import "PXP.h"
#import "PXP_Internal.h"
#import "PXPAccountInfo.h"
#import "PXPTransform.h"
#import "PXPDefines.h"
#import "NSString+PXPSecurity.h"
#import "NSURL+PXPUrl.h"

@implementation NSString (PXPImageTransform)

+ (NSString *)pxp_cdnUrl {
    NSString* host = [PXP sharedSDK].accountInfo.cdnUrl;
    if (host.length == 0) {
        return nil;
    } else {
        assert([host hasPrefix:@"http"]);
        return host;
    }
}

+ (NSString *)pxp_cdnPathForUrl:(NSString *)remoteUrl {

    NSString* result = nil;
    PXPUrlType type = [remoteUrl pxp_URLType];
    switch (type) {
        case PXPUrlTypeCDN: {
            result = remoteUrl;
            break;
        }
        case PXPUrlTypePath: {
            result = [NSString pxp_cdnUrl];
            break;
        }
        case PXPUrlTypeRemote: {
            NSString* host = [NSString pxp_cdnUrl];
            NSString* folder = @"remote.resources";
            result = [NSString stringWithFormat:@"%@/%@", host, folder];
            break;
        }
        default:
            break;
    }
    return result;
}

- (NSString *)pxp_imagePath {
    NSString* imagePath = nil;
    // URL ex.: http://cdn.example.com/app-id/image-path/../image.jpg
    NSMutableArray<NSString *> *pathComponents = [self.pathComponents mutableCopy];
    if (pathComponents.count > 1) {
        [pathComponents removeObjectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)]];
        imagePath = [pathComponents componentsJoinedByString:@"/"];
    }
    return imagePath;
}

- (NSString *)pxp_urlStringForTransform:( PXPTransform* _Nullable )transform {

    NSString *cdnUrl = [NSString pxp_cdnPathForUrl:self];
    NSString *name = [self lastPathComponent];
    assert(name != nil);

    NSString *url = nil;
    NSString *path = nil;
    NSString *fileName = nil;
    if (transform != nil) {
        NSString *extension = [transform formatString];
        NSString *quality = [transform qualityString];
        NSString *size = [transform sizeString];

        NSMutableArray *fileNameArray = [NSMutableArray new];
        SAFE_ADD_OBJECT(fileNameArray, size);
        SAFE_ADD_OBJECT(fileNameArray, quality);
        fileName = [fileNameArray componentsJoinedByString:@"_"];
        if (extension.length > 0) {
            fileName = [fileName stringByAppendingPathExtension:extension];
        }
    }

    NSMutableArray *pathArray = [NSMutableArray new];
    PXPUrlType type = [self pxp_URLType];
    if (type != PXPUrlTypeRemote) {
        SAFE_ADD_OBJECT(pathArray, name);
    } else {
        NSURL* url = [NSURL URLWithString:self];
        NSString* domain = url.host;
        NSMutableArray *md5Array = [NSMutableArray new];
        NSString* remoteUrlMD5 = [self MD5];
        NSString* firstPart = [remoteUrlMD5 substringToIndex:1];
        NSString* secondPart = [remoteUrlMD5 substringWithRange:NSMakeRange(1, 1)];
        NSString* thirdPart = [remoteUrlMD5 substringWithRange:NSMakeRange(2, 1)];
        NSString* lastPart = [remoteUrlMD5 substringFromIndex:3];
        SAFE_ADD_OBJECT(md5Array, domain);
        SAFE_ADD_OBJECT(md5Array, firstPart);
        SAFE_ADD_OBJECT(md5Array, secondPart);
        SAFE_ADD_OBJECT(md5Array, thirdPart);
        SAFE_ADD_OBJECT(md5Array, lastPart);
        NSString* md5Path = [md5Array componentsJoinedByString:@"/"];
        SAFE_ADD_OBJECT(pathArray, md5Path);
    }
    if (transform != nil) {
        SAFE_ADD_OBJECT(pathArray, @".pixpie.resource");
    }
    path = [pathArray componentsJoinedByString:@""];

    NSMutableArray *urlArray = [NSMutableArray new];
    SAFE_ADD_OBJECT(urlArray, cdnUrl);
    SAFE_ADD_OBJECT(urlArray, path);
    SAFE_ADD_OBJECT(urlArray, fileName);
    url = [urlArray componentsJoinedByString:@"/"];
    return url;
}

@end

