//
//  PXPAuthPrincipal.m
//  Pods
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import "PXPAuthPrincipal.h"
#import "PXPConfig.h"

@implementation PXPAuthPrincipal

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _appId = [PXPConfig defaultConfig].appId;
        _appKey = [PXPConfig defaultConfig].appSecret;
    }
    return self;
}

@end
