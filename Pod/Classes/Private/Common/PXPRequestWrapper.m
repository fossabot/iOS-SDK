//
//  PXPRequetWrapper.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPRequestWrapper.h"
#import "PXPConfig.h"
#import <AFNetworking/AFNetworking.h>
#import "PXPDefines.h"
#import "PXPURLProtocol.h"
#import "PXPDataMonitor.h"

@interface PXPRequestWrapper ()

@property (nonatomic, strong, readwrite) AFHTTPSessionManager* sessionManager;
@property (nonatomic, strong) NSString* backendUrl;

@end

@implementation PXPRequestWrapper

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _backendUrl = [PXPConfig defaultConfig].backend;
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.protocolClasses = @[[PXPURLProtocol class]];
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_backendUrl] sessionConfiguration:configuration];
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSSet* certs = [AFSecurityPolicy certificatesInBundle:mainBundle];
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:certs];
        policy.validatesDomainName = NO;
        policy.allowInvalidCertificates = NO;
        self.sessionManager.securityPolicy = policy;
        [[PXPDataMonitor sharedMonitor] addObserver:self forKeyPath:@"speedType" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [[PXPDataMonitor sharedMonitor] removeObserver:self forKeyPath:@"speedType" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"speedType"] && object == [PXPDataMonitor sharedMonitor]) {
        [PXPRequestWrapper setupQueue:[PXPRequestWrapper networkQueue]];
    }
}

- (PXPAPITask *)taskWithRequest:(NSURLRequest *)request
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(self.sessionManager != nil);
    NSString *uuid = [[NSUUID UUID] UUIDString];
    PXPAPITask *task = [[PXPAPITask alloc] initWithRequest:request queue:[PXPRequestWrapper networkQueue] identifier:uuid sessionManager:self.sessionManager evaluationBlock:^BOOL(NSURLSessionTask *task, NSError *error) {
        return (error.code == NSURLErrorTimedOut && [error.domain isEqualToString:NSURLErrorDomain]);
    } success:successBlock failure:failtureBlock];
    [task start];
    return task;
}

+ (NSOperationQueue *)networkQueue {
    static dispatch_once_t onceToken;
    static NSOperationQueue* sQueue = nil;
    dispatch_once(&onceToken, ^{
        sQueue = [NSOperationQueue new];
        [PXPRequestWrapper setupQueue:sQueue];
    });
    return sQueue;
}

+ (void)setupQueue:(NSOperationQueue*)aQueue {
    PXPDataSpeed speed = [PXPDataMonitor sharedMonitor].speedType;
    NSOperationQueue* queue = aQueue;
    switch (speed) {
        case PXPDataSpeedUndefined:
            queue.maxConcurrentOperationCount = 4;
            break;
        case PXPDataSpeedExtraLow:
            queue.maxConcurrentOperationCount = 1;
            break;
        case PXPDataSpeedLow:
            queue.maxConcurrentOperationCount = 1;
            break;
        case PXPDataSpeedMedium:
            queue.maxConcurrentOperationCount = 4;
            break;
        case PXPDataSpeedHigh:
            queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
            break;
        case PXPDataSpeedExtraHigh:
            queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
            break;
        case PXPDataSpeedNone:
            queue.maxConcurrentOperationCount = 0;
            break;
        default:
            queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
            break;
    }
}

@end
