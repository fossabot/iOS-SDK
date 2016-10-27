//
//  PXPHTTPProtocol.h
//  Pods
//
//  Created by Boris Polyakov on 7/5/16.
//
//

#import <Foundation/Foundation.h>

@protocol PXPURLProtocolDelegate;
@class PXPURLSessionDemux;

@interface PXPHTTPProtocol : NSURLProtocol

+ (void)setDelegate:(id<PXPURLProtocolDelegate>)newValue;
+ (id<PXPURLProtocolDelegate>)delegate;

@property (atomic, strong, readonly ) NSURLAuthenticationChallenge *pendingChallenge;

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential;
+ (NSURLCache *)defaultURLCache;

@end

@protocol PXPURLProtocolDelegate <NSObject>

@optional
- (BOOL)customHTTPProtocol:(PXPURLProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)arguments;

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol
      receivedResponseAfter:(NSTimeInterval)latency isRedirect:(BOOL)redirect;

- (void)customHTTPProtocol:(PXPURLProtocol *)protocol
          receivedBlockSize:(ssize_t)size;


@end
