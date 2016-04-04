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

@interface PXPAccountInfo ()

@property (nonatomic, readwrite, strong) NSString* authToken;
@property (nonatomic, readwrite, strong) NSString* cdnUrl;
@property (nonatomic, readwrite, strong) PXPAuthPrincipal* principal;
@property (nonatomic, readonly, strong) PXPAuthManager* authManager;
@property (nonatomic, strong) NSURLSessionDataTask* updateTask;

@end

@implementation PXPAccountInfo

- (instancetype)initWithPrincipal:(PXPAuthPrincipal *)principal authManager:(PXPAuthManager *)authManager {
    self = [super init];
    if (self != nil) {
        _principal = principal;
        _authManager = authManager;
    }
    return self;
}

- (void)update {
    [self.updateTask cancel];
    self.updateTask = [self.authManager authorizeWithCompletionBlock:^(NSDictionary *dict, NSError *error) {
        NSDictionary* userInfo = nil;
        if (error == nil) {
            [self setIfExistsValuesForKeysWithDictionary:dict];
        } else {
            userInfo = @{kPXPModelUpdateErrorKey : error};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kPXPModelUpdatedNotification object:self userInfo:userInfo];
    }];
}

@end
