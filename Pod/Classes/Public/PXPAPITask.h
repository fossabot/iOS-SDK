//
//  PXPAPITask.h
//  Pixpie
//
//  Created by Dmitry Osipa on 4/25/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^PXPRequestSuccessBlock)(NSURLSessionTask* task, id responseObject);
typedef void (^PXPRequestFailureBlock)(NSURLSessionTask* task, NSError* error);
typedef BOOL (^PXPRequestEvaluationBlock)(NSURLSessionTask* task, NSError* error);

@class AFHTTPSessionManager;

@interface PXPAPITask : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRequest:(NSURLRequest*)request
                          queue:(NSOperationQueue*)queue
                     identifier:(NSString*)identifier
                 sessionManager:(AFHTTPSessionManager*)sessionManager
                evaluationBlock:(PXPRequestEvaluationBlock)evaluationBlock
                        success:(PXPRequestSuccessBlock)successBlock
                        failure:(PXPRequestFailureBlock)failureBlock;
- (void)start;
- (void)cancel;

@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, assign) NSTimeInterval retryInterval;
@property (nonatomic, strong, readonly) NSURLRequest *originalRequest;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, copy, readonly) PXPRequestEvaluationBlock evaluationBlock;
@property (nonatomic, copy, readonly) PXPRequestSuccessBlock successBlock;
@property (nonatomic, copy, readonly) PXPRequestFailureBlock failureBlock;

@end
