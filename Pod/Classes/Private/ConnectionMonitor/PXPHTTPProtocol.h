//
//  PXPHTTPProtocol.h
//  Pixpie
//
//  Created by Boris Polyakov on 7/5/16.
//
//

#import <Foundation/Foundation.h>

@class PXPURLSessionDemux;
@class PXPHTTPProtocol;
@class PXPLogger;

@protocol PXPHTTPProtocolDataDelegate <NSObject>

- (void)HTTPProtocol:(PXPHTTPProtocol *)protocol receivedBlockSize:(ssize_t)size;

@optional
- (void)HTTPProtocol:(PXPHTTPProtocol *)protocol receivedResponseAfter:(NSTimeInterval)interval isRedirect:(BOOL)redirect;

@end

@protocol PXPHTTPProtocolAuthDelegate <NSObject>

@optional
- (BOOL)HTTPProtocol:(PXPHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)HTTPProtocol:(PXPHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)HTTPProtocol:(PXPHTTPProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@interface PXPHTTPProtocol : NSURLProtocol

@property (atomic, strong, readonly) NSURLAuthenticationChallenge *pendingChallenge;

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential;
+ (NSURLCache *)defaultURLCache;

@end

@interface PXPHTTPProtocol (PXPDelegates)

+ (void)setDataDelegate:(id<PXPHTTPProtocolDataDelegate>)dataDelegate;
+ (id<PXPHTTPProtocolDataDelegate>)dataDelegate;

+ (void)setAuthDelegate:(id<PXPHTTPProtocolAuthDelegate>)authDelegate;
+ (id<PXPHTTPProtocolAuthDelegate>)authDelegate;


@end

