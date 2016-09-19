//
//  PXPImageRequestWrapper.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;
@class AFHTTPSessionOperation;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PXPImageSuccessBlock)(NSURLSessionTask* task, id _Nullable responseObject);
typedef void (^PXPImageFailureBlock)(NSURLSessionTask* task, NSError* error);

@interface PXPImageRequestWrapper : NSObject

@property (nonatomic, strong, readonly) AFHTTPSessionManager* sessionManager;

- (instancetype)init;
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)config NS_DESIGNATED_INITIALIZER;

- (AFHTTPSessionOperation *)imageDownloadTaskForUrl:(NSString *)urlString
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                            success:(PXPImageSuccessBlock)successBlock
                                           failture:(PXPImageFailureBlock)failtureBlock;

- (AFHTTPSessionOperation *)imageDownloadTaskForRequest:(NSURLRequest *)request
                                         uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                       downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                                success:(PXPImageSuccessBlock)successBlock
                                               failture:(PXPImageFailureBlock)failtureBlock;

@end

NS_ASSUME_NONNULL_END