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

@interface PXP : NSObject

+ (instancetype)sharedSDK;

- (void)authWithApiKey:(NSString*)apiKey;

@property (nonatomic, readonly, assign) PXPState state;

@end
