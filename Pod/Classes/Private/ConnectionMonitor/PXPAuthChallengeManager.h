//
//  PXPAuthChallengeManager.h
//  Pixpie
//
//  Created by Dmitry Osipa on 11/1/16.
//
//

#import <Foundation/Foundation.h>
#import "PXPHTTPProtocol.h"

@interface PXPAuthChallengeManager : NSObject <PXPHTTPProtocolAuthDelegate>

- (BOOL)HTTPProtocol:(PXPHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)HTTPProtocol:(PXPHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
