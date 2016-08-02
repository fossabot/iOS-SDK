//
//  PXPAccountInfo.m
//  Pods
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import "PXPAccountInfo.h"
#import "PXPAuthManager.h"
#import "NSObject+SafeKVC.h"
#import <UIKit/UIApplication.h>

@interface PXPAccountInfo ()

@property (nonatomic, readwrite, strong) NSString* authToken;
@property (nonatomic, readwrite, strong) NSString* cdnUrl;
@property (nonatomic, readwrite, strong) PXPAuthPrincipal* principal;
@property (nonatomic, readonly, strong) PXPAuthManager* authManager;
@property (nonatomic, strong) PXPAPITask* updateTask;

@end

@implementation PXPAccountInfo

- (instancetype)initWithPrincipal:(PXPAuthPrincipal *)principal authManager:(PXPAuthManager *)authManager {
    self = [super init];
    if (self != nil) {
        _principal = principal;
        _authManager = authManager;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)update {
    if (self.principal == nil) return;
    [self.updateTask cancel];
    __weak typeof(self)weakSelf = self;
    self.updateTask = [self.authManager authorizeWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSDictionary* userInfo = nil;
        if (error == nil) {
            [strongSelf setIfExistsValuesForKeysWithDictionary:dict];
        } else if (error.code != NSURLErrorCancelled) {
            userInfo = @{kPXPModelUpdateErrorKey : error};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kPXPModelUpdatedNotification object:strongSelf userInfo:userInfo];
    }];
}

@end
