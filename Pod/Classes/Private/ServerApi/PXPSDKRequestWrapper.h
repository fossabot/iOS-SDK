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
- (instancetype)initWithAuthToken:(NSString*)token;
- (void)updateImageWithBundleId:(NSString*)bundleId
                          width:(NSInteger)width
                        quality:(NSInteger)quality
                           path:(NSString*)path
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failtureBlock:(PXPRequestFailureBlock)failtureBlock;

@end

NS_ASSUME_NONNULL_END
