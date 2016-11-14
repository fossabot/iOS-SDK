//
//  PXPAuthPrincipal.m
//  Pixpie
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import "PXPAuthPrincipal.h"
#import "PXPConfig.h"

@implementation PXPAuthPrincipal

- (instancetype)initWithAppSecret:(NSString*)appSecret
{
    self = [super init];
    if (self != nil) {
        _appId = [PXPConfig defaultConfig].appId;
        _appSecret = appSecret;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        PXPAuthPrincipal* otherPrincipal = (PXPAuthPrincipal*)object;
        return [self.appSecret isEqualToString:otherPrincipal.appSecret];
    } else {
        return [super isEqual:object];
    }
}



@end
