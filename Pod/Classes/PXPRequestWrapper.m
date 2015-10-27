//
//  PXPRequetWrapper.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPRequestWrapper.h"
#import "AFNetworking.h"
#import "NSString+PXPSecurity.h"

static NSString* const kPXPAuthMethod = @"/authentication/token/sdk";
#pragma mark - TBR
static NSString* const kPXPSalt = @"PIXPIE_SALT_VERY_SECURE";

@interface PXPRequestWrapper ()

@property (nonatomic, strong) AFHTTPSessionManager* sessionManager;
@property (nonatomic, strong) NSString* backendUrl;

@end

@implementation PXPRequestWrapper

+ (instancetype)sharedWrapper {
    static PXPRequestWrapper *_sharedWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWrapper = [PXPRequestWrapper new];
    });

    return _sharedWrapper;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
#warning to think how to implement this properly
        _backendUrl = @"http://159.203.120.198:9000";
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_backendUrl] sessionConfiguration:configuration];
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (void)authWithAppId:(NSString*)appId
               apiKey:(NSString*)apiKey
         successBlock:(PXPRequestSuccessBlock)successBlock
        failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    long timestamp = (long)[[NSDate date] timeIntervalSince1970];
    NSString *stringTimestamp = [NSString stringWithFormat:@"%ld", timestamp];
    NSString *toHash = [NSString stringWithFormat:@"%@%@%@", apiKey, kPXPSalt, stringTimestamp];
    NSString *hash = [toHash sha256];
#warning App Id should be used here
    NSDictionary *params = @{@"applicationId" : @"1",//appId,
                             @"timestamp" : stringTimestamp,
                             @"hash" : hash};

    NSString* url = [NSString stringWithFormat:@"%@%@", self.backendUrl, kPXPAuthMethod];
    [self.sessionManager GET:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        failtureBlock(error);
    }];
}

@end
