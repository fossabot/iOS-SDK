//
//  PXPAccountInfo.h
//  Pods
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import <Foundation/Foundation.h>

@class PXPAuthPrincipal;

@interface PXPAccountInfo : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDict:(NSDictionary*)dict principal:(PXPAuthPrincipal*)principal NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSString* authToken;
@property (nonatomic, strong, readonly) NSString* cdnUrl;
@property (nonatomic, strong, readonly) PXPAuthPrincipal* principal;

@end
