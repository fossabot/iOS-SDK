//
//  PXPAccountInfo.h
//  Pods
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import <Foundation/Foundation.h>
#import "PXPModelObject.h"

@class PXPAuthPrincipal;
@class PXPAuthManager;

@interface PXPAccountInfo : NSObject <PXPModelProtocol>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPrincipal:(PXPAuthPrincipal *)principal authManager:(PXPAuthManager *)authManager NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSString* authToken;
@property (nonatomic, strong, readonly) NSString* cdnUrl;
@property (nonatomic, assign, readonly) BOOL abEnabled;
@property (nonatomic, strong, readonly) PXPAuthPrincipal* principal;

@end
