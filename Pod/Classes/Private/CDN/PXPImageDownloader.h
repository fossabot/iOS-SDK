//
//  PXPImageDownloader.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import <Foundation/Foundation.h>
#import "PXPImageRequestWrapper.h"

@class PXPTransform;
@class PXPSDKRequestWrapper;

NS_ASSUME_NONNULL_BEGIN

@interface PXPImageDownloader : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSDKRequestWrapper:(PXPSDKRequestWrapper*)wrapper;
- (NSURLSessionDataTask*)imageTaskWithUrl:(NSURL*)url transform:(PXPTransform*)transform completion:(PXPImageRequestCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
