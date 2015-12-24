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

@interface PXPImageDownloader : NSObject

+ (instancetype)sharedDownloader;
- (NSURLSessionDataTask*)imageTaskWithUrl:(NSURL*)url transform:(PXPTransform*)transform completion:(PXPImageRequestCompletionBlock)completionBlock;

@end
