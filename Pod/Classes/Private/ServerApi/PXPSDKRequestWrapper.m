//
//  PXPSDKRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPSDKRequestWrapper.h"
#import "AFNetworking.h"

@implementation PXPSDKRequestWrapper

- (instancetype)initWithAuthToken:(NSString*)token
{
    self = [super init];
    if (self != nil) {
        [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"Auth-Token"];
    }
    return self;
}

- (void)updateImageWithBundleId:(NSString*)bundleId
                          width:(NSInteger)width
                        quality:(NSInteger)quality
                           path:(NSString*)path
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failtureBlock:(PXPRequestFailureBlock)failtureBlock {

}

@end
