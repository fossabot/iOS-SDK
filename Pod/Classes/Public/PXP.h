//
//  PXP.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PXPState) {
    PXPStateNotInitialized,
    PXPStateReady,
    PXPStateFailed
};

NS_ASSUME_NONNULL_BEGIN

extern NSString * const PXPStateChangeNotification;

@class PXPAccountInfo;
@class PXPSDKRequestWrapper;

@interface PXP : NSObject

+ (instancetype)sharedSDK;

- (void)authWithApiKey:(NSString*)apiKey;
- (void)authWithApiKey:(NSString*)apiKey userId:(NSString* _Nullable)userId;
+ (void)cleanUp;

@property (nonatomic, readonly, assign) PXPState state;

@end

NS_ASSUME_NONNULL_END
