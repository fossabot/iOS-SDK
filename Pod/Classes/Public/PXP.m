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
                              accountInfo:(PXPAccountInfo*)info;

@end

@interface PXP ()

@property (nonatomic, readwrite, assign) PXPState state;
@property (nonatomic, readwrite, strong) PXPFileManager *fileManager;
@property (nonatomic, readwrite, strong) PXPImageTaskManager* imageTaskManager;
@property (nonatomic, readwrite, strong) PXPAccountInfo *accountInfo;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPXPModelUpdatedNotification object:self.accountInfo];
}

- (void)authWithApiKey:(NSString *)apiKey {
   if (self.accountInfo == nil) {
        PXPAuthPrincipal *principal = [PXPAuthPrincipal new];
        principal.appId = [[NSBundle mainBundle] bundleIdentifier];
        principal.appKey = apiKey;
        PXPAuthManager* authManager = [[PXPAuthManager alloc] initWithPrincipal:principal];
       self.accountInfo = [[PXPAccountInfo alloc] initWithPrincipal:principal authManager:authManager];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authUpdate:) name:kPXPModelUpdatedNotification object:self.accountInfo];
       PXPSDKRequestWrapper *wrapper = [[PXPSDKRequestWrapper alloc] initWithAccountInfo:self.accountInfo];
       self.imageTaskManager = [[PXPImageTaskManager alloc] initWithSDKRequestWrapper:wrapper];
       self.fileManager = [[PXPFileManager alloc] initWithSDKRequestWrapper:wrapper accountInfo:self.accountInfo];
       [self.accountInfo update];
    }
}

- (void)authUpdate:(NSNotification *)note {

    NSDictionary *dict = note.userInfo;
    NSError *error = dict[kPXPModelUpdateErrorKey];
    if (error == nil) {
        self.state = PXPStateReady;
    } else {
        self.state = PXPStateFailed;
    }
}

@end
