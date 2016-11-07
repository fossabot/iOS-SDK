//
//  PXPAuthChallengeManager.m
//  Pods
//
//  Created by Dmitry Osipa on 11/1/16.
//
//

#import "PXPAuthChallengeManager.h"
#import "AFSecurityPolicy.h"

@interface PXPAuthChallengeManager ()

@property (nonatomic, strong) AFSecurityPolicy* securityPolicy;

@end

@implementation PXPAuthChallengeManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
    }
    return self;
}

- (BOOL)HTTPProtocol:(PXPHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    SecTrustRef trust = [protectionSpace serverTrust];
    return [self.securityPolicy evaluateServerTrust:trust forDomain:protectionSpace.host];
}

- (void)HTTPProtocol:(PXPHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    [protocol resolveAuthenticationChallenge:challenge withCredential:credential];
}

@end
