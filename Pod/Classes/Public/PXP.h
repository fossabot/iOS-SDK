//
//  PXP.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    PXPStateNotInitialized,
    PXPStateReady,
    PXPStateFailed
} PXPState;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const PXPStateChangeNotification;

@class PXPFileManager;
@class PXPAccountInfo;
@class PXPSDKRequestWrapper;

@interface PXP : NSObject

+ (instancetype)sharedSDK;

- (void)authWithApiKey:(NSString* __nullable)apiKey;
- (void)auth;

@property (nonatomic, readonly, assign) PXPState state;
@property (nonatomic, readonly, strong, nullable) PXPFileManager *fileManager;
@property (nonatomic, readonly, strong, nullable) PXPSDKRequestWrapper *wrapper;

@end

NS_ASSUME_NONNULL_END
