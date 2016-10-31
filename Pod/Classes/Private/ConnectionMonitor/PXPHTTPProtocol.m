//
//  PXPHTTPProtocol.m
//  Pods
//
//  Created by Boris Polyakov on 7/5/16.
//
//

#import "PXPHTTPProtocol.h"
#import "CanonicalRequest.h"
#import "CacheStoragePolicy.h"
#import "PXPURLSessionDemux.h"
#import "PXPDefines.h"

static NSString* const kPXPCanonicalPropertyKey = @"x-pixpie-is-canonical-request";
static NSString* const kPXPRecursivePropertyKey = @"x-pixpie-is-recursive-request";

typedef void (^ChallengeCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential);

BOOL PXPisOS8() {
    return (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 &&
            NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_x_Max);
}

@interface PXPHTTPProtocol() <NSURLSessionDataDelegate> {
    struct {
        BOOL didStartLoading:1;
        BOOL didStopLoading:1;
        BOOL didFinishLoading:1;
        BOOL didRecieveResponse:1;
        BOOL isCached:1;
    } _flags;
}


@property (atomic, strong, readwrite) NSThread *clientThread;       ///< The thread on which we should call the client.

@property (atomic, assign, readwrite) NSTimeInterval startTime;          ///< The start time of the request; written by client thread only; read by any thread.
@property (atomic, copy, readwrite) NSArray* modes;
@property (atomic, strong, readwrite) NSURLSessionDataTask* task;               ///< The NSURLSession task for that request; client thread only.

@property (atomic, strong, readwrite) NSURLAuthenticationChallenge* pendingChallenge;
@property (atomic, copy, readwrite) ChallengeCompletionHandler pendingChallengeCompletionHandler;  ///< The completion handler that matches pendingChallenge; main thread only;

@end

@implementation PXPHTTPProtocol (PXPDelegates)

static id<PXPHTTPProtocolDataDelegate> sDataDelegate;
static id<PXPHTTPProtocolAuthDelegate> sAuthDelegate;

+ (id<PXPHTTPProtocolDataDelegate>)dataDelegate
{
    id<PXPHTTPProtocolDataDelegate> result;
    @synchronized (self) {
        result = sDataDelegate;
    }
    return result;
}

+ (void)setDataDelegate:(id<PXPHTTPProtocolDataDelegate>)dataDelegate
{
    @synchronized (self) {
        sDataDelegate = dataDelegate;
    }
}

+ (id<PXPHTTPProtocolAuthDelegate>)authDelegate
{
    id<PXPHTTPProtocolAuthDelegate> result;
    @synchronized (self) {
        result = sAuthDelegate;
    }
    return result;
}

+ (void)setAuthDelegate:(id<PXPHTTPProtocolAuthDelegate>)authDelegate
{
    @synchronized (self) {
        sAuthDelegate = authDelegate;
    }
}

@end

@implementation PXPHTTPProtocol

#pragma mark - Object Lifecycle

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    self = [super initWithRequest:request
                   cachedResponse:cachedResponse
                           client:client];
    assert(client != nil);
    // can be called on any thread
    if (self != nil) {

        [[self class] HTTPProtocol:self logWithFormat:@"init for %@ from <%@ %p>", request.URL, [client class], client];
        BOOL isCanonical = ([PXPHTTPProtocol propertyForKey:kPXPCanonicalPropertyKey inRequest:request] != nil);
        if (!isCanonical) {
            request = [PXPHTTPProtocol canonicalRequestForRequest:request];
        }
        assert(request != nil);
    }
    return self;
}

- (void)dealloc
{
    // NSURLProtocol leaks, if redirection happens, so we make sure here, that we already released everything
    if (PXPisOS8()) {
        [self->_task cancel];
        self->_task = nil;
    } else {
        assert(self->_task == nil);                     // we should have cleared it by now
        assert(self->_pendingChallenge == nil);         // we should have cancelled it by now
        assert(self->_pendingChallengeCompletionHandler == nil);    // we should have cancelled it by now
    }
}

#pragma mark - Class Methods

+ (PXPURLSessionDemux *)sharedDemux
{
    static dispatch_once_t      sOnceToken;
    static PXPURLSessionDemux * sDemux;
    dispatch_once(&sOnceToken, ^{
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.allowsCellularAccess = YES;
        configuration.HTTPShouldUsePipelining = YES;
        configuration.timeoutIntervalForRequest = 15;
        configuration.HTTPMaximumConnectionsPerHost = 6;
        configuration.URLCache = nil;
        // You have to explicitly configure the session to use your own protocol subclass here
        // otherwise you don't see redirects <rdar://problem/17384498>.
        configuration.protocolClasses = @[ self ];
        sDemux = [[PXPURLSessionDemux alloc] initWithConfiguration:configuration];
    });
    return sDemux;
}

+ (void)HTTPProtocol:(PXPHTTPProtocol *)protocol logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3)
{
    va_list arguments;
    va_start(arguments, format);
#warning NSLog
    NSLogv(format, arguments);
    va_end(arguments);
}

#pragma mark - NSURLProtocol class methods overrides

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL        shouldAccept;
    NSURL *     url;
    NSString *  scheme;
    
    // Check the basics.  This routine is extremely defensive because experience has shown that
    // it can be called with some very odd requests <rdar://problem/15197355>.
    
    shouldAccept = (request != nil);
    if (shouldAccept) {
        url = request.URL;
        shouldAccept = (url != nil);
    }
    if ( ! shouldAccept ) {
        [self HTTPProtocol:nil logWithFormat:@"decline request (malformed)"];
    }
    
    // Decline our recursive requests.
    
    if (shouldAccept) {
        shouldAccept = ([self propertyForKey:kPXPRecursivePropertyKey inRequest:request] == nil);
        if ( ! shouldAccept ) {
            [self HTTPProtocol:nil logWithFormat:@"decline request %@ (recursive)", url];
        }
    }
    
    // Get the scheme.
    
    if (shouldAccept) {
        scheme = url.scheme.lowercaseString;
        shouldAccept = (scheme != nil);
        
        if ( ! shouldAccept ) {
            [self HTTPProtocol:nil logWithFormat:@"decline request %@ (no scheme)", url];
        }
    }
    
    // Look for "http" or "https".
    //
    // Flip either or both of the following to YESes to control which schemes go through this custom
    // NSURLProtocol subclass.
    
    if (shouldAccept) {
        shouldAccept = [scheme isEqual:@"http"] || [scheme isEqual:@"https"];
        
        if ( ! shouldAccept ) {
            [self HTTPProtocol:nil logWithFormat:@"decline request %@ (scheme mismatch)", url];
        } else {
            [self HTTPProtocol:nil logWithFormat:@"accept request %@", url];
        }
    }
    
    return shouldAccept;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    assert(request != nil);
    // can be called on any thread
    
    // Canonicalising a request is quite complex, so all the heavy lifting has
    // been shuffled off to a separate module.
    
    NSMutableURLRequest* canonicalRequest = CanonicalRequestForRequest(request);
    
    [PXPHTTPProtocol setProperty:@(YES) forKey:kPXPCanonicalPropertyKey inRequest:canonicalRequest];
    
    return canonicalRequest;
}

#pragma mark - NSURLProtocol overrides

- (void)startLoading
{
    NSMutableURLRequest* recursiveRequest = nil;
    NSMutableArray* calculatedModes = nil;
    NSString* currentMode = nil;
    if (_flags.didStartLoading) {
        if (!_flags.didFinishLoading)
        {
            _flags.didStopLoading = NO;
        }
        return;
    }

    // At this point we kick off the process of loading the URL via NSURLSession.
    // The thread that calls this method becomes the client thread.
    _flags.didStartLoading = 1;
    _flags.isCached = 0;
    assert(self.clientThread == nil);           // you can't call -startLoading twice
    assert(self.task == nil);


    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at
    // you UIWebView!) we can be called from a non-standard thread which then runs a
    // non-standard run loop mode waiting for the request to finish.  We detect this
    // non-standard mode and add it to the list of run loop modes we use when scheduling
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode"
    // but it's better not to hard-code that here.

    assert(self.modes == nil);
    calculatedModes = [NSMutableArray array];
    [calculatedModes addObject:NSDefaultRunLoopMode];
    currentMode = [NSRunLoop currentRunLoop].currentMode;
    if ( (currentMode != nil) && ! [currentMode isEqual:NSDefaultRunLoopMode] ) {
        [calculatedModes addObject:currentMode];
    }
    self.modes = calculatedModes;
    assert([self.modes count] > 0);

    // Create new request that's a clone of the request we were initialised with,
    // except that it has our 'recursive request flag' property set on it.

    recursiveRequest = [self.request mutableCopy];
    assert(recursiveRequest != nil);

    [[self class] setProperty:@YES forKey:kPXPRecursivePropertyKey inRequest:recursiveRequest];
    
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    if (currentMode == nil) {
        [[self class] HTTPProtocol:self logWithFormat:@"start %@", recursiveRequest.URL];
    } else {
        [[self class] HTTPProtocol:self logWithFormat:@"start %@ (mode %@)", recursiveRequest.URL, currentMode];
    }

    // Latch the thread we were called on, primarily for debugging purposes.

    self.clientThread = [NSThread currentThread];

    // Once everything is ready to go, create a data task with the new request.

    if (self.cachedResponse != nil)
    {
        _flags.isCached = 1;
        [self.client URLProtocol:self cachedResponseIsValid:self.cachedResponse];
        [self handleResponse:self.cachedResponse.response task:nil cachePolicy:NSURLCacheStorageNotAllowed];
        [self handleData:self.cachedResponse.data];
        [self handleFinishLoading];
        [self stopLoading];
        return;
    }


    self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];

    assert(self.task != nil);

    [self.task resume];
}

- (void)stopLoading
{
    // The implementation just cancels the current load (if it's still running).
    
    [[self class] HTTPProtocol:self logWithFormat:@"stop (elapsed %.1f)", [NSDate timeIntervalSinceReferenceDate] - self.startTime];
    
    assert(self.clientThread != nil);
    _flags.didStopLoading = 1;
    assert([NSThread currentThread] == self.clientThread);
    if (_flags.didFinishLoading)
    {
        [self cancelPendingChallenge];
        if (!PXPisOS8()) {
            [self.task cancel];
            self.task = nil;
        }
    }
    // Don't nil out self.modes; see property declaration comments for a a discussion of this.
}

#pragma mark - Authentication challenge handling

/*! Performs the block on the specified thread in one of specified modes.
 *  \param thread The thread to target; nil implies the main thread.
 *  \param modes The modes to target; nil or an empty array gets you the default run loop mode.
 *  \param block The block to run.
 */

- (void)performOnThread:(NSThread *)thread modes:(NSArray *)modes block:(dispatch_block_t)block
{
    // thread may be nil
    // modes may be nil
    assert(block != nil);

    if (thread == nil) {
        thread = [NSThread mainThread];
    }
    if (modes.count == 0) {
        modes = @[ NSDefaultRunLoopMode ];
    }
    [self performSelector:@selector(onThreadPerformBlock:) onThread:thread withObject:[block copy] waitUntilDone:NO modes:modes];
}

/*! A helper method used by -performOnThread:modes:block:. Runs in the specified context
 *  and simply calls the block.
 *  \param block The block to run.
 */

- (void)onThreadPerformBlock:(dispatch_block_t)block
{
    assert(block != nil);
    block();
}

/*! Called by our NSURLSession delegate callback to pass the challenge to our delegate.
 *  \description This simply passes the challenge over to the main thread.
 *  We do this so that all accesses to pendingChallenge are done from the main thread,
 *  which avoids the need for extra synchronisation.
 *
 *  By the time this runes, the NSURLSession delegate callback has already confirmed with
 *  the delegate that it wants the challenge.
 *
 *  Note that we use the default run loop mode here, not the common modes.  We don't want
 *  an authorisation dialog showing up on top of an active menu (-:
 *
 *  Also, we implement our own 'perform block' infrastructure because Cocoa doesn't have
 *  one <rdar://problem/17232344> and CFRunLoopPerformBlock is inadequate for the
 *  return case (where we need to pass in an array of modes; CFRunLoopPerformBlock only takes
 *  one mode).
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
    assert(challenge != nil);
    assert(completionHandler != nil);
    assert([NSThread currentThread] == self.clientThread);
    

    
     [self performOnThread:nil modes:nil block:^{
        [self mainThreadDidReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }];
}

/*! The main thread side of authentication challenge processing.
 *  \details If there's already a pending challenge, something has gone wrong and
 *  the routine simply cancels the new challenge.  If our delegate doesn't implement
 *  the -HTTPProtocol:canAuthenticateAgainstProtectionSpace: delegate callback,
 *  we also cancel the challenge.  OTOH, if all goes well we simply call our delegate
 *  with the challenge.
 *  \param challenge The authentication challenge to process; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)mainThreadDidReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
    assert(challenge != nil);
    assert(completionHandler != nil);
    assert([NSThread isMainThread]);

    if (self.pendingChallenge != nil) {


        // Our delegate is not expecting a second authentication challenge before resolving the
        // first.  Likewise, NSURLSession shouldn't send us a second authentication challenge
        // before we resolve the first.  If this happens, assert, log, and cancel the challenge.
        //
        // Note that we have to cancel the challenge on the thread on which we received it,
        // namely, the client thread.
        
        [[self class] HTTPProtocol:self logWithFormat:@"challenge %@ cancelled; other challenge pending", challenge.protectionSpace.authenticationMethod];
        assert(NO);
        [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        id<PXPHTTPProtocolAuthDelegate>  strongDelegate;
        
        strongDelegate = [[self class] authDelegate];
        
        // Tell the delegate about it.  It would be weird if the delegate didn't support this
        // selector (it did return YES from -HTTPProtocol:canAuthenticateAgainstProtectionSpace:
        // after all), but if it doesn't then we just cancel the challenge ourselves (or the client
        // thread, of course).
        
        if ( ! [strongDelegate respondsToSelector:@selector(HTTPProtocol:canAuthenticateAgainstProtectionSpace:)] ) {
            [[self class] HTTPProtocol:self logWithFormat:@"challenge %@ cancelled; no delegate method", challenge.protectionSpace.authenticationMethod];
            assert(NO);
            [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
        } else {
            
            // Remember that this challenge is in progress.
            
            self.pendingChallenge = challenge;
            self.pendingChallengeCompletionHandler = completionHandler;
            
            // Pass the challenge to the delegate.
            
            [[self class] HTTPProtocol:self logWithFormat:@"challenge %@ passed to delegate", challenge.protectionSpace.authenticationMethod];
            [strongDelegate HTTPProtocol:self didReceiveAuthenticationChallenge:self.pendingChallenge];
        }
    }
}

/*! Cancels an authentication challenge that hasn't made it to the pending challenge state.
 *  \details This routine is called as part of various error cases in the challenge handling
 *  code.  It cancels a challenge that, for some reason, we've failed to pass to our delegate.
 *
 *  The routine is always called on the main thread but bounces over to the client thread to
 *  do the actual cancellation.
 *  \param challenge The authentication challenge to cancel; must not be nil.
 *  \param completionHandler The associated completion handler; must not be nil.
 */

- (void)clientThreadCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
#pragma unused(challenge)
    assert(challenge != nil);
    assert(completionHandler != nil);
    assert([NSThread isMainThread]);

    [self performOnThread:self.clientThread modes:self.modes block:^{
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }];
}

/*! Cancels an authentication challenge that /has/ made to the pending challenge state.
 *  \details This routine is called by -stopLoading to cancel any challenge that might be
 *  pending when the load is cancelled.  It's always called on the client thread but
 *  immediately bounces over to the main thread (because .pendingChallenge is a main
 *  thread only value).
 */

- (void)cancelPendingChallenge
{
    assert([NSThread currentThread] == self.clientThread);

    // Just pass the work off to the main thread.  We do this so that all accesses
    // to pendingChallenge are done from the main thread, which avoids the need for
    // extra synchronisation.

    [self performOnThread:nil modes:nil block:^{
        if (self.pendingChallenge == nil) {
            // This is not only not unusual, it's actually very typical.  It happens every time you shut down
            // the connection.  Ideally I'd like to not even call -mainThreadCancelPendingChallenge when
            // there's no challenge outstanding, but the synchronisation issues are tricky.  Rather than solve
            // those, I'm just not going to log in this case.
            //
            // [[self class] HTTPProtocol:self logWithFormat:@"challenge not cancelled; no challenge pending"];
        } else {
            id<PXPHTTPProtocolAuthDelegate>  strongeDelegate;
            NSURLAuthenticationChallenge *  challenge;
            
            strongeDelegate = [[self class] authDelegate];
            
            challenge = self.pendingChallenge;
            self.pendingChallenge = nil;
            self.pendingChallengeCompletionHandler = nil;
            
            if ([strongeDelegate respondsToSelector:@selector(HTTPProtocol:didCancelAuthenticationChallenge:)]) {
                [[self class] HTTPProtocol:self logWithFormat:@"challenge %@ cancellation passed to delegate", challenge.protectionSpace.authenticationMethod];
                [strongeDelegate HTTPProtocol:self didCancelAuthenticationChallenge:challenge];
            } else {
                [[self class] HTTPProtocol:self logWithFormat:@"challenge %@ cancellation failed; no delegate method", challenge.protectionSpace.authenticationMethod];
                // If we managed to send a challenge to the client but can't cancel it, that's bad.
                // There's nothing we can do at this point except log the problem.
                assert(NO);
            }
        }
    }];
}

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential
{
    assert(challenge == self.pendingChallenge);
    // credential may be nil
    assert([NSThread isMainThread]);
    assert(self.clientThread != nil);

    if (challenge != self.pendingChallenge) {
        [[self class] HTTPProtocol:self logWithFormat:@"challenge resolution mismatch (%@ / %@)", challenge, self.pendingChallenge];
        // This should never happen, and we want to know if it does, at least in the debug build.
        assert(NO);
    } else {
        ChallengeCompletionHandler  completionHandler;
        
        // We clear out our record of the pending challenge and then pass the real work
        // over to the client thread (which ensures that the challenge is resolved on
        // the same thread we received it on).

        completionHandler = self.pendingChallengeCompletionHandler;
        self.pendingChallenge = nil;
        self.pendingChallengeCompletionHandler = nil;

        [self performOnThread:self.clientThread modes:self.modes block:^{
            if (credential == nil) {
                [[self class] HTTPProtocol:self logWithFormat:@"challenge %@ resolved without credential", challenge.protectionSpace.authenticationMethod];
                completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
            } else {
                [[self class] HTTPProtocol:self logWithFormat:@"challenge %@ resolved with <%@ %p>", challenge.protectionSpace.authenticationMethod, [credential class], credential];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            }
        }];
    }
}

#pragma mark - NSURLSession delegate callbacks

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest* redirectRequest = nil;

#pragma unused(session)
#pragma unused(task)
    assert(task == self.task);
    assert(response != nil);
    assert(newRequest != nil);
#pragma unused(completionHandler)
    assert(completionHandler != nil);
    assert([NSThread currentThread] == self.clientThread);
    
    [[self class] HTTPProtocol:self logWithFormat:@"will redirect from %@ to %@", response.URL, newRequest.URL];
    
    id<PXPHTTPProtocolDataDelegate> dlg = [[self class] dataDelegate];
    if ([dlg respondsToSelector:@selector(HTTPProtocol:receivedResponseAfter:isRedirect:)]) {
        NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
        [dlg HTTPProtocol:self receivedResponseAfter:interval isRedirect:YES];
    }

    // The new request was copied from our old request, so it has our magic property.  We actually
    // have to remove that so that, when the client starts the new request, we see it.  If we
    // don't do this then we never see the new request and thus don't get a chance to change
    // its caching behaviour.
    //
    // We also cancel our current connection because the client is going to start a new request for
    // us anyway.

    assert([[self class] propertyForKey:kPXPRecursivePropertyKey inRequest:newRequest] != nil);

    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:kPXPRecursivePropertyKey inRequest:redirectRequest];

    // Tell the client about the redirect.

    [self.client URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];

    // Stop our load.  The CFNetwork infrastructure will create a new NSURLProtocol instance to run
    // the load of the redirect.

    // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
    // which specificallys traps and ignores the error.

    [self.task cancel];
    self.task = nil;

    [self handleError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    BOOL result;

#pragma unused(session)
#pragma unused(task)
    assert(task == self.task);
    assert(challenge != nil);
    assert(completionHandler != nil);
    assert([NSThread currentThread] == self.clientThread);

    // Ask our delegate whether it wants this challenge.  We do this from this thread, not the main thread,
    // to avoid the overload of bouncing to the main thread for challenges that aren't going to be customised
    // anyway.
    
    id<PXPHTTPProtocolAuthDelegate> strongeDelegate = [[self class] authDelegate];

    result = NO;
    if ([strongeDelegate respondsToSelector:@selector(HTTPProtocol:canAuthenticateAgainstProtectionSpace:)]) {
        result = [strongeDelegate HTTPProtocol:self canAuthenticateAgainstProtectionSpace:challenge.protectionSpace];
    }

    // If the client wants the challenge, kick off that process.  If not, resolve it by doing the default thing.

    if (result) {
        [[self class] HTTPProtocol:self logWithFormat:@"can authenticate %@", challenge.protectionSpace.authenticationMethod];
        
        [self didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        [[self class] HTTPProtocol:self logWithFormat:@"cannot authenticate %@", challenge.protectionSpace.authenticationMethod];
        
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLCacheStoragePolicy cacheStoragePolicy;
    NSInteger               statusCode = 0;

#pragma unused(session)
#pragma unused(dataTask)
    assert(dataTask == self.task);
    assert(response != nil);
    assert(completionHandler != nil);
    assert([NSThread currentThread] == self.clientThread);
    
    id<PXPHTTPProtocolDataDelegate> dlg = [[self class] dataDelegate];
    if ([dlg respondsToSelector:@selector(HTTPProtocol:receivedResponseAfter:isRedirect:)]) {
        NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
        [dlg HTTPProtocol:self receivedResponseAfter:interval isRedirect:NO];
    }

    // Pass the call on to our client.  The only tricky thing is that we have to decide on a
    // cache storage policy, which is based on the actual request we issued, not the request
    // we were given.

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.task.originalRequest, (NSHTTPURLResponse *) response);
    }
    else
    {
        assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = 42;
    }
    
    [[self class] HTTPProtocol:self logWithFormat:@"received response %zd / %@ with cache storage policy %zu", (ssize_t) statusCode, response.URL, (size_t) cacheStoragePolicy];

    [self handleResponse:response task:dataTask cachePolicy:cacheStoragePolicy];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
#pragma unused(session)
#pragma unused(dataTask)
    assert(dataTask == self.task);
    assert(data != nil);
    assert([NSThread currentThread] == self.clientThread);
    
    id<PXPHTTPProtocolDataDelegate> dlg = [[self class] dataDelegate];
    if ([dlg respondsToSelector:@selector(HTTPProtocol:receivedBlockSize:)] &&
        !_flags.isCached) {
            [dlg HTTPProtocol:self receivedBlockSize:data.length];
    }

    // Just pass the call on to our client.
    // Task may be alredy cancelled and nullified at that point, but this callback is still executed.
    // So sometimes we dont need the data anyway
    if (dataTask == self.task && !_flags.didStopLoading)
    {
        [self handleData:data];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
#pragma unused(session)
#pragma unused(dataTask)
    assert(dataTask == self.task);
    assert(proposedResponse != nil);
    assert(completionHandler != nil);
    assert([NSThread currentThread] == self.clientThread);
    
    // We implement this delegate callback purely for the purposes of logging.
    
    [[self class] HTTPProtocol:self logWithFormat:@"will cache response"];
    NSURLCache* cache = [PXPHTTPProtocol defaultURLCache];
    [cache storeCachedResponse:proposedResponse forRequest:dataTask.originalRequest];
    completionHandler(nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
// An NSURLSession delegate callback.  We pass this on to the client.
{
#pragma unused(session)
#pragma unused(task)
    assert( (self.task == nil) || (task == self.task) );        // can be nil in the 'cancel from -stopLoading' case
    assert([NSThread currentThread] == self.clientThread);

    // Just log and then, in most cases, pass the call on to our client.

    if (error == nil)
    {
        [self handleFinishLoading];
    }
    else if ([error.domain isEqual:NSURLErrorDomain] && (error.code == NSURLErrorCancelled)) {
        // Do nothing.  This happens in two cases:
        //
        // o during a redirect, in which case the redirect code has already told the client about
        //   the failure
        //
        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't
        //   want to know about the failure
        _flags.didFinishLoading = YES;
        [[self class] HTTPProtocol:self logWithFormat:@"error %@ / %d", error.domain, (int) error.code];
        
        [self.client URLProtocol:self didFailWithError:error];
    }
    else
    {
        [self handleError:error];
    }
    
    // We do need to clean up the connection here; the system will not call, if hasn't already called,
    // -stopLoading to do that.
    [self stopLoading];
}

#pragma mark - Callbacks

- (void)handleError:(NSError*)error
{
    assert(error);
    _flags.didFinishLoading = YES;
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)handleData:(NSData*)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)handleFinishLoading
{
    _flags.didFinishLoading = YES;
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)handleResponse:(NSURLResponse *)response
                  task:(NSURLSessionDataTask *)task
           cachePolicy:(NSURLCacheStoragePolicy)policy
{
    assert(response);
    _flags.didRecieveResponse = YES;
    [self checkCache:response task:task];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:policy];
}

- (void)checkCache:(NSURLResponse *)response task:(NSURLSessionDataTask *)dataTask {
    if (dataTask == nil) return;
    NSURLCache* cache = [PXPHTTPProtocol defaultURLCache];
    NSCachedURLResponse *cachedResponse = [cache cachedResponseForRequest:dataTask.currentRequest];
    if (cachedResponse == nil) {
        cache = [NSURLCache sharedURLCache];
        cachedResponse = [cache cachedResponseForRequest:dataTask.currentRequest];
    }
    NSHTTPURLResponse *httpCacheResponse = (NSHTTPURLResponse *)cachedResponse.response;
    _flags.isCached = (httpCacheResponse != nil);
}

+ (NSURLCache *)defaultURLCache {
    static NSURLCache* sCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* identifier = PXP_IDENTIFY_CLASS(self.class);
        sCache = [[NSURLCache alloc] initWithMemoryCapacity: 20 * 1024 * 1024
                                               diskCapacity: 150 * 1024 * 1024
                                                   diskPath: identifier];
    });
    return sCache;
}

@end
