//
//  PXPAuthRequestWrapper.h
//  Pixpie
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPRequestWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXPAuthRequestWrapper : PXPRequestWrapper

+ (instancetype)sharedWrapper;
- (PXPAPITask *)authWithAppId:(NSString*)appId
                       apiKey:(NSString*)apiKey
                     deviceId:(NSString*)deviceId
                clientSdkType:(NSNumber*)clientSdkType
                       userId:(NSString * _Nullable )userId
            deviceDescription:(NSString*)deviceDescription
                   sdkVersion:(NSString*)sdkVersion
                 successBlock:(PXPRequestSuccessBlock)successBlock
                failtureBlock:(PXPRequestFailureBlock)failtureBlock;

@end

NS_ASSUME_NONNULL_END
