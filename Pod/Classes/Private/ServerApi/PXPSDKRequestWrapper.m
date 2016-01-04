//
//  PXPSDKRequestWrapper.m
//  Pods
//
//  Created by Dmitry Osipa on 12/24/15.
//
//

#import "PXPSDKRequestWrapper.h"
#import "AFNetworking.h"

static NSString* const kPXPUpdateImageRequestPath = @"/images/newResolution/%@/%@/%@/%@";

@interface PXPSDKRequestWrapper ()

@property (nonatomic, strong, readonly) NSString* appId;
@property (nonatomic, strong, readonly) NSString* token;

@end

@implementation PXPSDKRequestWrapper

- (instancetype)initWithAuthToken:(NSString*)token appId:(NSString*)appId
{
    self = [super init];
    if (self != nil) {
        [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"AuthToken"];
        _appId = appId;
        _token = token;
    }
    return self;
}

- (void)updateImageWithWidth:(NSString*)width
                     quality:(NSString*)quality
                        path:(NSString*)path
                successBlock:(PXPRequestSuccessBlock)successBlock
               failtureBlock:(PXPRequestFailureBlock)failtureBlock {

    assert(path != nil);
    NSString* apiPath = [NSString stringWithFormat:kPXPUpdateImageRequestPath, self.appId, width, quality, path];
    NSString* url = [self.backendUrl stringByAppendingString:apiPath];
    [self.sessionManager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failtureBlock(error);
    }];
}

@end
