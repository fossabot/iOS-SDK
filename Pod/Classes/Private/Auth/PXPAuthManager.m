//
//  PXPAuthManager.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPAuthManager.h"
#import "PXPAuthRequestWrapper.h"
#import "PXPAuthPrincipal.h"
#import "PXPAccountInfo.h"
#import "PXPConfig.h"

@interface PXPAuthManager ()

@property (nonatomic, strong) PXPAuthRequestWrapper *requestWrapper;
@property (nonatomic, strong) PXPAuthPrincipal *principal;

@end

@implementation PXPAuthManager

- (instancetype)initWithPrincipal:(PXPAuthPrincipal*)principal
{
    self = [super init];
    if (self != nil) {
        _requestWrapper = [PXPAuthRequestWrapper sharedWrapper];
        _principal = principal;
    }
    return self;
}

- (PXPAPITask *)authorizeWithCompletionBlock:(PXPAuthBlock)block {

    return [self.requestWrapper authWithAppId:self.principal.appId
                                       apiKey:self.principal.appSecret
                                     deviceId:[PXPConfig defaultConfig].deviceId
                                clientSdkType:[PXPConfig defaultConfig].clientSdkType
                                       userId:self.principal.userId
                            deviceDescription:[PXPConfig defaultConfig].deviceDescription
                                   sdkVersion:[PXPConfig defaultConfig].sdkVersion
                                 successBlock:^(NSURLSessionTask* task, id responseObject) {
                                     block(responseObject, nil);
                                 } failtureBlock:^(NSURLSessionTask* task, NSError *error) {
                                     block(nil, error);
                                 }];
}

@end
