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

typedef void (^PXPImageRequestCompletionBlock)(NSURL* _Nullable url, UIImage  * _Nullable responseObject, NSError * _Nullable error);
typedef void (^PXPProgressBlock)(NSProgress *progress);

@interface PXPImageTaskManager : NSObject

- (instancetype)init;

- (NSString*)imageDownloadTaskWithRequest:(NSURLRequest *)request
                                transform:(PXPTransform *)transform
                           uploadProgress:(PXPProgressBlock _Nullable)uploadProgress
                         downloadProgress:(PXPProgressBlock _Nullable)downloadProgress
                               completion:(PXPImageRequestCompletionBlock)completionBlock;
- (NSString*)imageDownloadTaskWithUrl:(NSURL *)url
                            transform:(PXPTransform *)transform
                              headers:(NSDictionary * _Nullable)headers
                       uploadProgress:(PXPProgressBlock _Nullable)uploadProgress
                     downloadProgress:(PXPProgressBlock _Nullable)downloadProgress
                           completion:(PXPImageRequestCompletionBlock)completionBlock;
- (NSString*)imageDownloadTaskWithPath:(NSString *)path
                             transform:(PXPTransform *)transform
                               headers:(NSDictionary * _Nullable)headers
                        uploadProgress:(PXPProgressBlock _Nullable)uploadProgress
                      downloadProgress:(PXPProgressBlock _Nullable)downloadProgress
                            completion:(PXPImageRequestCompletionBlock)completionBlock;
- (NSString *)imageUploadTaskWithImage:(UIImage *)image
                        uploadProgress:(PXPProgressBlock)uploadProgress
                            completion:(PXPImageRequestCompletionBlock)completionBlock;
- (void)cancelTaskWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
