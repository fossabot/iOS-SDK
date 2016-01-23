//
//  PXP.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXP.h"
#import "PXPAuthManager.h"
#import "PXPAuthPrincipal.h"
#import "PXPAccountInfo.h"
#import "PXP_Internal.h"
#import "PXPImageTaskManager.h"
#import "PXPSDKRequestWrapper.h"
#import "PXPNetworkMonitor.h"
#import "PXPFileManager.h"


@interface PXPFileManager (Private)

- (instancetype)initWithSDKRequestWrapper:(PXPSDKRequestWrapper *)sdkRequestWrapper
                                     root:(NSString *)root;

@end

@interface PXP ()

@property (nonatomic, strong) PXPAuthManager *authManager;
@property (nonatomic, readwrite, assign) PXPState state;
@property (nonatomic, readwrite, strong) PXPFileManager *fileManager;

@end

@implementation PXP

+ (instancetype)sharedSDK {
    static PXP *_sharedPXP = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPXP = [PXP new];
    });

    return _sharedPXP;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _state = PXPStateNotInitialized;
        _imageTaskManager = [[PXPImageTaskManager alloc] initWithSDKRequestWrapper:nil];
        [[PXPNetworkMonitor sharedMonitor] startMonitoring];
    }
    return self;
}

- (void)dealloc {
    [[PXPNetworkMonitor sharedMonitor] stopMonitoring];
}

- (void)authWithApiKey:(NSString *)apiKey {
   if (self.authManager == nil) {
        PXPAuthPrincipal *principal = [PXPAuthPrincipal new];
        principal.appId = [[NSBundle mainBundle] bundleIdentifier];
        principal.appKey = apiKey;
        self.authManager = [[PXPAuthManager alloc] initWithPrincipal:principal];
        [self.authManager authorizeWithCompletionBlock:^(PXPAccountInfo *accountInfo, NSError *error) {
            if (accountInfo != nil) {
                self.state = PXPStateReady;
                self.accountInfo = accountInfo;
                PXPSDKRequestWrapper *wrapper = [[PXPSDKRequestWrapper alloc] initWithAuthToken:accountInfo.authToken appId:accountInfo.principal.appId];
                self.imageTaskManager = [[PXPImageTaskManager alloc] initWithSDKRequestWrapper:wrapper];
                self.fileManager = [[PXPFileManager alloc] initWithSDKRequestWrapper:wrapper root:self.accountInfo.cdnUrl];
            } else {
                self.state = PXPStateFailed;
            }
        }];
    }
}

@end
