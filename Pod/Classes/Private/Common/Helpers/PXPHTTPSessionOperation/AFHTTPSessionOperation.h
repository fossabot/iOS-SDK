//
//  AFSessionOperation.h
//
//  Created by Robert Ryan on 8/6/15.
//  Copyright (c) 2015 Robert Ryan. All rights reserved.
//

#import "PXPAsynchronousOperation.h"

@class AFHTTPSessionManager;

NS_ASSUME_NONNULL_BEGIN

@interface AFHTTPSessionOperation : PXPAsynchronousOperation

/** The NSURLSessionTask associated with this operation
 */
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *task;

/*!
 *  @brief Creates an `AFHTTPSessionOperation` with the specified request.
 *
 *  @param manager          The AFURLSessionManager for the operation.
 *  @param request          The HTTP request for the request.
 *  @param uploadProgress   A block that is called as the upload of the request body progresses.
 *  @param downloadProgress A block that is called as the download of the server response progresses.
 *  @param success          A block object to be executed if and when the task successfully finishes.
 *  @param failure          A block object to be executed if and when the task fails.
 *
 *  @return AFURLSessionOperation that can be added to a NSOperationQueue.
 */
+ (instancetype)operationWithManager:(AFHTTPSessionManager *)manager
                             request:(NSURLRequest *)request
                      uploadProgress:(void  (^ _Nullable )(NSProgress *uploadProgress)) uploadProgress
                    downloadProgress:(void (^ _Nullable )(NSProgress *downloadProgress)) downloadProgress
                             success:(void (^)(NSURLSessionDataTask *, id _Nullable))success
                             failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end

NS_ASSUME_NONNULL_END