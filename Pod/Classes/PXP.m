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

@interface PXP ()

@property (nonatomic, strong) PXPAuthManager* authManager;
@property (nonatomic, readwrite, assign) PXPState state;


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
    }
    return self;
}

- (void)authWithApiKey:(NSString*)apiKey {
    if (self.authManager == nil) {
        PXPAuthPrincipal* principal = [PXPAuthPrincipal new];
        principal.appId = [[NSBundle mainBundle] bundleIdentifier];
        principal.appKey = apiKey;
        self.authManager = [[PXPAuthManager alloc] initWithPrincipal:principal];
        [self.authManager authorizeWithCompletionBlock:^(PXPAccountInfo *accountInfo, NSError *error) {
            if (accountInfo != nil) {
                self.state = PXPStateReady;
            }
            else {
                self.state = PXPStateFailed;
            }
        }];
    }
}

@end
