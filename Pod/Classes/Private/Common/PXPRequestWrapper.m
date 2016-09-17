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
#import "PXPQueueManager.h"

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
    }
    return self;
}

- (PXPAPITask *)taskWithRequest:(NSURLRequest *)request
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(self.sessionManager != nil);
    NSString *uuid = [[NSUUID UUID] UUIDString];
    PXPAPITask *task = [[PXPAPITask alloc] initWithRequest:request queue:[PXPQueueManager networkQueue] identifier:uuid sessionManager:self.sessionManager evaluationBlock:^BOOL(NSURLSessionTask *task, NSError *error) {
        return (error.code == NSURLErrorTimedOut && [error.domain isEqualToString:NSURLErrorDomain]);
    } success:successBlock failure:failtureBlock];
    [task start];
    return task;
}

@end
