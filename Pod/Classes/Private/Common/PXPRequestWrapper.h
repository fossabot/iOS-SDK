//
//  PXPRequetWrapper.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXPAPITask.h"

@class AFHTTPSessionManager;

@interface PXPRequestWrapper : NSObject

@property (nonatomic, strong, readonly) NSString* backendUrl;
@property (nonatomic, strong, readonly) AFHTTPSessionManager* sessionManager;

- (PXPAPITask *)taskWithRequest:(NSURLRequest *)request
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failtureBlock:(PXPRequestFailureBlock)failtureBlock;

@end
