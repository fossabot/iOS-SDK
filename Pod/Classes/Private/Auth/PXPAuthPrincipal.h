//
//  PXPAuthPrincipal.h
//  Pixpie
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PXPAuthPrincipal : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppSecret:(NSString*)appSecret NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSString* appId;
@property (nonatomic, strong, readonly) NSString* appSecret;
@property (nonatomic, strong, nullable) NSString* userId;

@end

NS_ASSUME_NONNULL_END
