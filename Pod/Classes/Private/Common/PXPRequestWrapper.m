//
//  PXPRequetWrapper.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPRequestWrapper.h"
#import "AFNetworking.h"

@interface PXPRequestWrapper ()

@property (nonatomic, strong, readwrite) AFHTTPSessionManager* sessionManager;
@property (nonatomic, strong) NSString* backendUrl;

@end

@implementation PXPRequestWrapper

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
#warning to think how to implement this properly
        _backendUrl = @"https://api.pixpie.co:9444";
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_backendUrl] sessionConfiguration:configuration];
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSSet* certs = [AFSecurityPolicy certificatesInBundle:mainBundle];
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:certs];
        policy.validatesDomainName = NO;
        policy.allowInvalidCertificates = YES;
        self.sessionManager.securityPolicy = policy;
    }
    return self;
}

@end