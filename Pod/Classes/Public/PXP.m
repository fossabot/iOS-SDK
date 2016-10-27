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
#import "PXPSDKRequestWrapper.h"
#import "PXPNetworkMonitor.h"
#import "PXPDataMonitor.h"
#import "PXPTrafficMonitor.h"
#import "PXPHTTPProtocol.h"
#import "PXPURLSessionDemux.h"

NSString* const PXPStateChangeNotification = @"co.pixpie.notification.PXPStateChange";

@interface PXP ()

@property (nonatomic, readwrite, assign) PXPState state;
@property (nonatomic, readwrite, strong) PXPImageTaskManager* imageTaskManager;
@property (nonatomic, readwrite, strong) PXPAccountInfo *accountInfo;
@property (nonatomic, readwrite, strong) PXPSDKRequestWrapper *wrapper;
@property (nonatomic, readwrite, strong) NSTimer *authTimer;

@end

@implementation PXP

#pragma mark - Public Interface

+ (instancetype)sharedSDK {
    static PXP *_sharedPXP = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPXP = [PXP new];
    });

    return _sharedPXP;
}

- (void)authWithApiKey:(NSString *)apiKey {
    PXPAuthPrincipal *principal = [[PXPAuthPrincipal alloc] initWithAppSecret:apiKey];
    [self authWithPrincipal:principal];
}

- (void)authWithApiKey:(NSString*)apiKey userId:(NSString* _Nullable)userId {
    PXPAuthPrincipal *principal = [[PXPAuthPrincipal alloc] initWithAppSecret:apiKey];
    principal.userId = userId;
    [self authWithPrincipal:principal];
}

#pragma mark - Private Interface

- (void)authWithPrincipal:(PXPAuthPrincipal*)principal {
    if (![self.accountInfo.principal isEqual:principal]) {
        PXPAuthManager* authManager = [[PXPAuthManager alloc] initWithPrincipal:principal];
        self.accountInfo = [[PXPAccountInfo alloc] initWithPrincipal:principal authManager:authManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authUpdate:) name:kPXPModelUpdatedNotification object:self.accountInfo];
        self.wrapper = [[PXPSDKRequestWrapper alloc] initWithAccountInfo:self.accountInfo];
        [self.accountInfo update];
    }
}

- (void)authUpdate:(NSNotification *)note {

    if (self.accountInfo == nil) return;
    NSDictionary *dict = note.userInfo;
    NSError *error = dict[kPXPModelUpdateErrorKey];
    if (error == nil) {
        self.state = PXPStateReady;
        if (self.authTimer) {
            [self.authTimer invalidate];
            self.authTimer = nil;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPXPNetworkChangedNotification object:nil];
    } else {
        self.state = PXPStateFailed;
        if ([error.domain isEqualToString:NSURLErrorDomain] &&
            error.code <= NSURLErrorTimedOut &&
            error.code >= NSURLErrorBadServerResponse) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kPXPNetworkChangedNotification object:nil];
            [self scheduleReauth];
        }
    }
}

- (void)networkChanged:(NSNotification *)note
{
    if ([PXPNetworkMonitor sharedMonitor].currentNetworkTechnology) {
        [self timerCall];
    }
}

- (void)scheduleReauth
{
    self.authTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerCall) userInfo:nil repeats:YES];
}

- (void)timerCall
{
    [self.accountInfo update];
}

- (void)setState:(PXPState)state {
    if (state == _state) {
        return;
    }

    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PXPStateChangeNotification object:self];
}

+ (void)cleanUp {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [PXPHTTPProtocol.defaultURLCache removeAllCachedResponses];
}

#pragma mark - Object Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [PXPDataMonitor sharedMonitor];
        _state = PXPStateNotInitialized;
        [[PXPNetworkMonitor sharedMonitor] startMonitoring];
        [PXPTrafficMonitor sharedMonitor];
    }
    return self;
}

- (void)dealloc {
    [[PXPNetworkMonitor sharedMonitor] stopMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPXPModelUpdatedNotification object:self.accountInfo];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPXPNetworkChangedNotification object:nil];
}

@end
