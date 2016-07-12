//
//  PXPSDKRequestWrapper.h
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPRequestWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@class PXPAccountInfo;

@interface PXPSDKRequestWrapper : PXPRequestWrapper

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAccountInfo:(PXPAccountInfo *)info NS_DESIGNATED_INITIALIZER;
- (PXPAPITask *)updateImageWithWidth:(NSString*)width
                             quality:(NSString*)quality
                                path:(NSString*)path
                        successBlock:(PXPRequestSuccessBlock)successBlock
                       failtureBlock:(PXPRequestFailureBlock)failtureBlock;
- (PXPAPITask *)uploadImageTaskAtUrl:(NSString *)url
                               width:(NSString *)width
                             quality:(NSString *)quality
                              params:(NSDictionary*)requestHeaders
                        successBlock:(PXPRequestSuccessBlock)successBlock
                       failtureBlock:(PXPRequestFailureBlock)failtureBlock;
- (NSURLSessionDataTask *)uploadImageTaskForImage:(UIImage *)image
                                           toPath:(NSString *)path
                                     successBlock:(PXPRequestSuccessBlock)successBlock
                                    failtureBlock:(PXPRequestFailureBlock)failtureBlock;
- (NSURLSessionDataTask *)uploadImageTaskForStream:(NSInputStream *)stream
                                          mimeType:(NSString *)mimeType
                                            length:(int64_t)length
                                            toPath:(NSString *)path
                                      successBlock:(PXPRequestSuccessBlock)successBlock
                                     failtureBlock:(PXPRequestFailureBlock)failtureBlock;
- (PXPAPITask *)imagesAtPath:(NSString *)path
                successBlock:(PXPRequestSuccessBlock)successBlock
               failtureBlock:(PXPRequestFailureBlock)failtureBlock;

@end

NS_ASSUME_NONNULL_END
