//
//  PXPAuthManager.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PXPAuthPrincipal;
@class PXPAccountInfo;

//typedef void(^PXPCheckAuthBlock)(BOOL isAuthorized);
typedef void(^PXPAuthBlock)(NSDictionary* accountInfo, NSError* error);

@interface PXPAuthManager : NSObject

@property (nonatomic, assign, readonly) BOOL isAuthorized;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPrincipal:(PXPAuthPrincipal *)principal NS_DESIGNATED_INITIALIZER;
- (NSURLSessionDataTask *)authorizeWithCompletionBlock:(PXPAuthBlock)block;
//- (void)checkAuth:(PXPAuthBlock)block;

@end
