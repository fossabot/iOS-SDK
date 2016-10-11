//
//  PXPAuthRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPAuthRequestWrapper.h"
#import "NSString+PXPSecurity.h"
#import "PXPConfig.h"
#import "PXPQueueManager.h"
#import <AFNetworking/AFNetworking.h>

static NSString* const kPXPAuthMethod = @"/authentication/token/client_sdk";

@interface PXPAuthRequestWrapper ()

@property (nonatomic, strong) NSString* requestSalt;

@end

@implementation PXPAuthRequestWrapper

+ (instancetype)sharedWrapper {
    static PXPAuthRequestWrapper *_sharedWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWrapper = [PXPAuthRequestWrapper new];
    });
    return _sharedWrapper;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

- (PXPAPITask *)authWithAppId:(NSString*)appId
                       apiKey:(NSString*)apiKey
                     deviceId:(NSString*)deviceId
                clientSdkType:(NSNumber*)clientSdkType
                       userId:(NSString*)userId
            deviceDescription:(NSString*)deviceDescription
                   sdkVersion:(NSString*)sdkVersion
                 successBlock:(PXPRequestSuccessBlock)successBlock
                failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    NSString* salt = PXPConfig.defaultConfig.requestSalt;
    long timestamp = (long)[[NSDate date] timeIntervalSince1970];
    NSString *stringTimestamp = [NSString stringWithFormat:@"%ld", timestamp];
    NSString *toHash = [NSString stringWithFormat:@"%@%@%@", apiKey, salt, stringTimestamp];
    NSString *hash = [toHash sha256];
    NSDictionary *params = @{@"reverseUrlId" : appId,
                             @"timestamp" : stringTimestamp,
                             @"hash" : hash,
                             @"clientSdkType" : clientSdkType,
                             @"deviceUniqueId" : deviceId,
                             @"userUniqueId" : userId == nil ? deviceId : userId,
                             @"deviceDescription" : deviceDescription,
                             @"sdkVersion" : sdkVersion};

    NSString* url = [NSString stringWithFormat:@"%@%@", self.backendUrl, kPXPAuthMethod];
    NSError* error = nil;
    NSURLRequest* request = [self.sessionManager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:params error:&error];
    NSAssert(error == nil, @"Auth Request error is not nil");
    PXPAPITask* task = [self taskWithRequest:request successBlock:successBlock failtureBlock:failtureBlock];
    return task;
}

- (PXPAPITask *)taskWithRequest:(NSURLRequest *)request
                   successBlock:(PXPRequestSuccessBlock)successBlock
                  failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(self.sessionManager != nil);
    NSString *uuid = [[NSUUID UUID] UUIDString];
    PXPAPITask *task = [[PXPAPITask alloc] initWithRequest:request queue:[PXPQueueManager networkQueue] identifier:uuid sessionManager:self.sessionManager evaluationBlock:^BOOL(NSURLSessionTask *task, NSError *error) {
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        return (response == nil);
    } success:successBlock failure:failtureBlock];
    [task start];
    return task;
}


@end
