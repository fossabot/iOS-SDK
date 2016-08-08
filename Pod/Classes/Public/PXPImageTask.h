//
//  PXPImageTask.h
//  PixpieFramework
//
//  Created by Dmitry Osipa on 4/14/16.
//
//

#import <Foundation/Foundation.h>

@class UIImage;
@class PXPTransform;
@class PXPImageRequestWrapper;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PXPProgressBlock)(NSProgress *progress);
typedef void (^PXPImageRequestCompletionBlock)(NSURL* _Nullable url, UIImage  * _Nullable responseObject, NSError * _Nullable error);

@interface PXPImageTask : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUrl:(NSString*)urlString
                     method:(NSString*)method
                  transfrom:(PXPTransform*)transform
                     params:(nullable NSDictionary*)params
                    headers:(nullable NSDictionary*)headers
                 identifier:(NSString*)identifier
             requestWrapper:(PXPImageRequestWrapper*)requestWrapper
             uploadProgress:(PXPProgressBlock)uploadProgress
           downloadProgress:(PXPProgressBlock)downloadProgress
                 completion:(PXPImageRequestCompletionBlock)completion;

- (instancetype)initWithRequest:(NSURLRequest*)request
                      transfrom:(PXPTransform*)transform
                     identifier:(NSString*)identifier
                 requestWrapper:(PXPImageRequestWrapper*)requestWrapper
                 uploadProgress:(PXPProgressBlock)uploadProgress
               downloadProgress:(PXPProgressBlock)downloadProgress
                     completion:(PXPImageRequestCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, strong, readonly) NSURLRequest *originalRequest;
@property (nonatomic, strong, readonly) PXPTransform *transform;
@property (nonatomic, copy, readonly) PXPProgressBlock uploadProgress;
@property (nonatomic, copy, readonly) PXPProgressBlock downloadProgress;
@property (nonatomic, copy, readonly) PXPImageRequestCompletionBlock completionBlock;
@property (nonatomic, assign, readonly, getter=isExecuting) BOOL executing;

- (void)start;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
