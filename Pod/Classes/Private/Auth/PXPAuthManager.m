//
//  PXPAuthManager.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPAuthManager.h"
#import "PXPRequestWrapper.h"
#import "PXPAuthPrincipal.h"
#import "PXPAccountInfo.h"

@interface PXPAuthManager ()

@property (nonatomic, strong) PXPRequestWrapper *requestWrapper;
@property (nonatomic, strong) PXPAuthPrincipal *principal;

@end

@implementation PXPAuthManager

- (instancetype)initWithPrincipal:(PXPAuthPrincipal*)principal
{
    self = [super init];
    if (self != nil) {
        _requestWrapper = [PXPRequestWrapper sharedWrapper];
        _principal = principal;
    }
    return self;
}

- (void)authorizeWithCompletionBlock:(PXPAuthBlock)block {

// if (authorized) {block(YES); return;}
    [self.requestWrapper authWithAppId:self.principal.appId
                                apiKey:self.principal.appKey
                          successBlock:^(id responseObject) {
                              PXPAccountInfo* info = [[PXPAccountInfo alloc] initWithDict:responseObject];
                              block(info, nil);
                          } failtureBlock:^(NSError *error) {
                              block(nil, error);
                          }];
}

@end
