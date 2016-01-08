//
//  PXPImageRequestWrapper.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PXPImageDownloadRequestCompletionBlock)(UIImage  * _Nullable responseObject, NSError * _Nullable error);
typedef void (^PXPImageUploadRequestCompletionBlock)(id _Nullable responseObject, NSError * _Nullable error);

@interface PXPImageRequestWrapper : NSObject

- (NSURLSessionDataTask *)imageDownloadTaskForUrl:(NSURL *)url
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;
- (NSURLSessionDataTask *)imageUploadTaskForStream:(NSInputStream *)stream
                                          mimeType:(NSString *)mimeType
                                            length:(int64_t)length
                                             toURL:(NSURL *)url
                                        completion:(PXPImageUploadRequestCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
