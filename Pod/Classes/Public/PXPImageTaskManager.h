//
//  PXPImageDownloader.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

@import Foundation;
@import UIKit;

@class PXPTransform;
@class PXPSDKRequestWrapper;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PXPImageDownloadRequestCompletionBlock)(UIImage  * _Nullable responseObject, NSError * _Nullable error);
typedef void (^PXPImageUploadRequestCompletionBlock)(id _Nullable responseObject, NSError * _Nullable error);

@interface PXPImageTaskManager : NSObject

- (instancetype)init;
- (NSURLSessionDataTask*)imageDownloadTaskWithUrl:(NSURL *)url
                                        transform:(PXPTransform *)transform
                                       completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;
- (NSURLSessionDataTask*)imageDownloadTaskWithPath:(NSString *)path
                                         transform:(PXPTransform *)transform
                                        completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;
- (NSURLSessionDataTask*)imageDownloadWithRemoteUrl:(NSURL *)url
                                          transform:(PXPTransform *)transform
                                         completion:(PXPImageDownloadRequestCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
