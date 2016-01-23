//
//  PXPSDKRequestWrapper.h
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPRequestWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXPSDKRequestWrapper : PXPRequestWrapper

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAuthToken:(NSString *)token
                            appId:(NSString *)appId NS_DESIGNATED_INITIALIZER;
- (void)updateImageWithWidth:(NSString *)width
                     quality:(NSString *)quality
                        path:(NSString *)path
                successBlock:(PXPRequestSuccessBlock)successBlock
               failtureBlock:(PXPRequestFailureBlock)failtureBlock;
- (NSURLSessionDataTask *)uploadImageTaskForStream:(NSInputStream *)stream
                                          mimeType:(NSString *)mimeType
                                            length:(int64_t)length
                                            toPath:(NSString *)path
                                      successBlock:(PXPRequestSuccessBlock)successBlock
                                     failtureBlock:(PXPRequestFailureBlock)failtureBlock;
- (NSURLSessionDataTask *)uploadImageTaskAtUrl:(NSString *)url
                                         width:(NSString *)width
                                       quality:(NSString *)quality
                                  successBlock:(PXPRequestSuccessBlock)successBlock
                                 failtureBlock:(PXPRequestFailureBlock)failtureBlock;
- (NSURLSessionDataTask *)imagesAtPath:(NSString *)path
                          successBlock:(PXPRequestSuccessBlock)successBlock
                         failtureBlock:(PXPRequestFailureBlock)failtureBlock;

@end

NS_ASSUME_NONNULL_END
