//
//  PXPRequetWrapper.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^PXPRequestSuccessBlock)(id responseObject);
typedef void (^PXPRequestFailureBlock)(NSError* error);

@interface PXPRequestWrapper : NSObject

+ (instancetype)sharedWrapper;
- (void)authWithAppId:(NSString*)appId
               apiKey:(NSString*)apiKey
         successBlock:(PXPRequestSuccessBlock)successBlock
        failtureBlock:(PXPRequestFailureBlock)failtureBlock;

@end
