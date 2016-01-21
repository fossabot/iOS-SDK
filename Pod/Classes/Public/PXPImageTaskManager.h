//
//  PXPImageDownloader.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import <Foundation/Foundation.h>

@class PXPTransform;
@class PXPSDKRequestWrapper;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PXPImageDownloadRequestCompletionBlock)(UIImage  * _Nullable responseObject, NSError * _Nullable error);
typedef void (^PXPImageUploadRequestCompletionBlock)(id _Nullable responseObject, NSError * _Nullable error);

@interface PXPImageTaskManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSDKRequestWrapper:(PXPSDKRequestWrapper * _Nullable)wrapper;
- (NSURLSessionDataTask*)imageDownloadTaskWithUrl:(NSURL*)url
                                        transform:(PXPTransform *)transform
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;
- (NSURLSessionDataTask*)imageDownloadTaskWithPath:(NSString*)path
                                         transform:(PXPTransform *)transform
                                        completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;
- (NSURLSessionDataTask*)imageDownloadWithRemoteUrl:(NSURL*)url
                                          transform:(PXPTransform*)transform
                                         completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
