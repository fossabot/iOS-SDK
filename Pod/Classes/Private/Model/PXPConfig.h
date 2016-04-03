//
//  PXPConfig.h
//  Pods
//
//  Created by Dmitry Osipa on 4/3/16.
//
//

#import <Foundation/Foundation.h>

@interface PXPConfig : NSObject

+ (instancetype)defaultConfig;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString* backend;
@property (nonatomic, readonly) NSString* appSecret;
@property (nonatomic, readonly) NSString* requestSalt;
@property (nonatomic, readonly) NSString* appId;

@end
