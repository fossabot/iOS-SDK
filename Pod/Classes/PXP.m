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

@interface PXP ()

@property (nonatomic, strong) PXPAuthManager* authManager;

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

- (void)authWithApiKey:(NSString*)apiKey {
    if (self.authManager == nil) {
        PXPAuthPrincipal* principal = [PXPAuthPrincipal new];
        principal.appId = [[NSBundle mainBundle] bundleIdentifier];
        principal.appKey = apiKey;
        self.authManager = [[PXPAuthManager alloc] initWithPrincipal:principal];
        [self.authManager authorizeWithCompletionBlock:^(PXPAccountInfo *accountInfo, NSError *error) {
            if (accountInfo != nil) {
                NSLog(@"%@", accountInfo);
            }
            else {
                NSLog(@"%@", error);
            }
        }];
    }
}

@end
