//
//  NSURL+PXPUrl.m
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import "NSURL+PXPUrl.h"
#import "PXPDefines.h"
#import "NSString+PXPImageTransform.h"

@implementation NSURL (PXPUrl)

- (PXPUrlType)pxp_URLType {
    NSString* cdnUrl = [NSString pxp_cdnUrl];
    if (cdnUrl != nil && [self.absoluteString hasPrefix:cdnUrl]) {
        return PXPUrlTypeCDN;
    } else if (self.host == nil) {
        return PXPUrlTypePath;
    } else if ([self.scheme isEqualToString:@"http"] || [self.scheme isEqualToString:@"https"] ) {
        return PXPUrlTypeRemote;
    } else {
        return PXPUrlTypeOther;
    }
}

- (NSString*)pathAndQuery {
    NSString* path = self.path;
    NSString* query = self.query;
    NSMutableArray* array = [NSMutableArray new];
    SAFE_ADD_OBJECT(array, path);
    SAFE_ADD_OBJECT(array, query);
    return [array componentsJoinedByString:@""];
}

@end

@implementation NSString (PXPUrlTypes)

- (PXPUrlType)pxp_URLType {
    NSURL* url = [NSURL URLWithString:self];
    return ([url pxp_URLType]);
}

@end
