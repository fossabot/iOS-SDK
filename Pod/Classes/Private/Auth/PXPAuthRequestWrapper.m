//
//  PXPAuthRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPAuthRequestWrapper.h"
#import "AFNetworking.h"
#import "NSString+PXPSecurity.h"

static NSString* const kPXPAuthMethod = @"/authentication/token/sdk";
#warning To be refactored
static NSString* const kPXPSalt = @"PIXPIE_SALT_VERY_SECURE";

@implementation PXPAuthRequestWrapper

+ (instancetype)sharedWrapper {
    static PXPAuthRequestWrapper *_sharedWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWrapper = [PXPAuthRequestWrapper new];
    });
    return _sharedWrapper;
}

- (void)authWithAppId:(NSString*)appId
               apiKey:(NSString*)apiKey
         successBlock:(PXPRequestSuccessBlock)successBlock
        failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    long timestamp = (long)[[NSDate date] timeIntervalSince1970];
    NSString *stringTimestamp = [NSString stringWithFormat:@"%ld", timestamp];
    NSString *toHash = [NSString stringWithFormat:@"%@%@%@", apiKey, kPXPSalt, stringTimestamp];
    NSString *hash = [toHash sha256];
    NSDictionary *params = @{@"reverseUrlId" : appId,
                             @"timestamp" : stringTimestamp,
                             @"hash" : hash};

    NSString* url = [NSString stringWithFormat:@"%@%@", self.backendUrl, kPXPAuthMethod];
    [self.sessionManager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        failtureBlock(error);
    }];
}

@end
