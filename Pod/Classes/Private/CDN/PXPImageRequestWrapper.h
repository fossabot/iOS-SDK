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
                                       parameters:(NSDictionary * _Nullable )params
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;
- (NSURLSessionDataTask *)imageDownloadTaskForRequest:(NSURLRequest *)request
                                           completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;

+ (NSURLSessionConfiguration *)defaultImageSessionConfiguration;

@end

NS_ASSUME_NONNULL_END
