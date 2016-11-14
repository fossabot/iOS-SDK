//
//  PXPConfig.h
//  Pixpie
//
//  Created by Dmitry Osipa on 4/3/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PXPConfig : NSObject

+ (instancetype)defaultConfig;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly, strong) NSString* backend;
@property (nonatomic, readonly, strong) NSString* requestSalt;
@property (nonatomic, readonly, strong) NSString* appId;
@property (nonatomic, readonly, strong) NSNumber* clientSdkType;
@property (nonatomic, readonly, strong) NSString* sdkVersion;
@property (nonatomic, readonly, strong) NSString* deviceId;
@property (nonatomic, readonly, strong) NSString* deviceDescription;

@end

NS_ASSUME_NONNULL_END
