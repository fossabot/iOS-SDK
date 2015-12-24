//
//  PXPAuthRequestWrapper.h
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPRequestWrapper.h"

@interface PXPAuthRequestWrapper : PXPRequestWrapper

+ (instancetype)sharedWrapper;
- (void)authWithAppId:(NSString*)appId
               apiKey:(NSString*)apiKey
         successBlock:(PXPRequestSuccessBlock)successBlock
        failtureBlock:(PXPRequestFailureBlock)failtureBlock;

@end
