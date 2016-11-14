//
//  PXPAPIManager.h
//  Pixpie
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPRequestWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@class PXPAccountInfo;
@class UIImage;

@interface PXPAPIManager : PXPRequestWrapper

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAccountInfo:(PXPAccountInfo *)info NS_DESIGNATED_INITIALIZER;

- (NSURLSessionDataTask *)imagesAtPath:(NSString *)path
                          successBlock:(PXPRequestSuccessBlock)successBlock
                         failureBlock:(PXPRequestFailureBlock)failureBlock;

- (NSURLSessionDataTask * _Nullable)deleteImages:(NSArray<NSString*> * _Nonnull )images
                                            dirs:(NSArray<NSString*> * _Nonnull )dirs
                                    successBlock:(PXPRequestSuccessBlock)successBlock
                                   failureBlock:(PXPRequestFailureBlock)failureBlock;

- (NSURLSessionDataTask *)uploadTaskForImage:(UIImage *)image
                                      toPath:(NSString *)path
                                successBlock:(PXPRequestSuccessBlock)successBlock
                               failureBlock:(PXPRequestFailureBlock)failureBlock;

- (NSURLSessionDataTask *)uploadImageTaskForStream:(NSInputStream *)stream
                                          mimeType:(NSString *)mimeType
                                            length:(int64_t)length
                                            toPath:(NSString *)path
                                      successBlock:(PXPRequestSuccessBlock)successBlock
                                     failureBlock:(PXPRequestFailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
