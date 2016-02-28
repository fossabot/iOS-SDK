//
//  PXPImageRequestWrapper.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import <Foundation/Foundation.h>
#import "PXPImageTaskManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXPImageRequestWrapper : NSObject

- (instancetype)init;
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)config NS_DESIGNATED_INITIALIZER;

- (NSURLSessionDataTask *)imageDownloadTaskForUrl:(NSURL *)url
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;

+ (NSURLSessionConfiguration *)defaultImageSessionConfiguration;

@end

NS_ASSUME_NONNULL_END
