//
//  PXP.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXP : NSObject

+ (instancetype)sharedSDK;

- (void)authWithApiKey:(NSString*)apiKey;

@end
