//
//  PXPURLSessionDemux.m
//  Pixpie
//
//  Created by Boris Polyakov on 7/5/16.
//
//

#import "PXPURLSessionDemux.h"
#import "PXPDefines.h"

@interface PXPSURLSessionDemuxTaskInfo : NSObject

- (instancetype)initWithTask:(NSURLSessionDataTask *)task delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes;

@property (atomic, strong, readonly ) NSURLSessionDataTask *        task;
@property (atomic, strong, readonly ) id<NSURLSessionDataDelegate>  delegate;
@property (atomic, strong, readonly ) NSThread *                    thread;
@property (atomic, copy,   readonly ) NSArray *                     modes;

- (void)performBlock:(dispatch_block_t)block;
- (void)invalidate;

@end

@interface PXPSURLSessionDemuxTaskInfo ()

@property (atomic, strong, readwrite, nullable) id<NSURLSessionDataDelegate>  delegate;
@property (atomic, strong, readwrite, nullable) NSThread *                    thread;

@end

@implementation PXPSURLSessionDemuxTaskInfo

- (instancetype)initWithTask:(NSURLSessionDataTask *)task delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes
{
    assert(task != nil);
    assert(delegate != nil);
    assert(modes != nil);

    self = [super init];
    if (self != nil) {
        self->_task = task;
        self->_delegate = delegate;
        self->_thread = [NSThread currentThread];
        self->_modes = [modes copy];
    }
    return self;
}

- (void)performBlock:(dispatch_block_t)block
{
    assert(self.delegate != nil);
    assert(self.thread != nil);
    [self performSelector:@selector(performBlockOnClientThread:) onThread:self.thread withObject:[block copy] waitUntilDone:NO modes:self.modes];
}

- (void)performBlockOnClientThread:(dispatch_block_t)block
{
    assert([NSThread currentThread] == self.thread);
    block();
}

- (void)invalidate
{
    self.delegate = nil;
    self.thread = nil;
}

@end

@interface PXPURLSessionDemux () <NSURLSessionDataDelegate>

@property (atomic, strong, readonly ) NSMutableDictionary<NSNumber*, PXPSURLSessionDemuxTaskInfo*> * taskInfoByTaskID;       // keys NSURLSessionTask taskIdentifier, values are SessionManager
@property (atomic, strong, readonly ) NSOperationQueue *    sessionDelegateQueue;

@end

@implementation PXPURLSessionDemux

- (instancetype)init
{
    return [self initWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self != nil) {
        self->_configuration = [configuration copy];
        self->_taskInfoByTaskID = [[NSMutableDictionary alloc] init];
        self->_sessionDelegateQueue = [[NSOperationQueue alloc] init];
        self->_sessionDelegateQueue.maxConcurrentOperationCount = 1;
        self->_sessionDelegateQueue.name = PXP_IDENTIFY_CLASS(self.class);
        assert(self->_sessionDelegateQueue.name.length > 0);
        self->_session = [NSURLSession sessionWithConfiguration:self->_configuration delegate:self delegateQueue:self->_sessionDelegateQueue];
        self->_session.sessionDescription = self->_sessionDelegateQueue.name;
    }
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray * _Nullable )modes
{
    NSURLSessionDataTask *          task;
    PXPSURLSessionDemuxTaskInfo *    taskInfo;

    assert(request != nil);
    assert(delegate != nil);
    // modes may be nil

    if (modes.count == 0) {
        modes = @[ NSDefaultRunLoopMode ];
    }

    task = [self.session dataTaskWithRequest:request];
    assert(task != nil);

    taskInfo = [[PXPSURLSessionDemuxTaskInfo alloc] initWithTask:task delegate:delegate modes:modes];

    @synchronized (self) {
        self.taskInfoByTaskID[@(task.taskIdentifier)] = taskInfo;
    }

    return task;
}

- (PXPSURLSessionDemuxTaskInfo *)taskInfoForTask:(NSURLSessionTask *)task
{
    PXPSURLSessionDemuxTaskInfo *    result;

    assert(task != nil);

    @synchronized (self) {
        result = self.taskInfoByTaskID[@(task.taskIdentifier)];
        assert(result != nil);
    }
    return result;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    PXPSURLSessionDemuxTaskInfo * taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session task:task willPerformHTTPRedirection:response newRequest:newRequest completionHandler:completionHandler];
        }];
    } else {
        completionHandler(newRequest);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    PXPSURLSessionDemuxTaskInfo *taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
        }];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

/*
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler
{
    PXPSURLSessionDemuxTaskInfo * taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:needNewBodyStream:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session task:task needNewBodyStream:completionHandler];
        }];
    } else {
        completionHandler(nil);
    }
}
 */

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    PXPSURLSessionDemuxTaskInfo * taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    PXPSURLSessionDemuxTaskInfo * taskInfo = [self taskInfoForTask:task];

    // This is our last delegate callback so we remove our task info record.

    @synchronized (self) {
        [self.taskInfoByTaskID removeObjectForKey:@(taskInfo.task.taskIdentifier)];
    }

    // Call the delegate if required.  In that case we invalidate the task info on the client thread
    // after calling the delegate, otherwise the client thread side of the -performBlock: code can
    // find itself with an invalidated task info.

    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session task:task didCompleteWithError:error];
            [taskInfo invalidate];
        }];
    } else {
        [taskInfo invalidate];
    }
}

#pragma mark - NSURLSessionDataTaskDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    PXPSURLSessionDemuxTaskInfo *    taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
        }];
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    PXPSURLSessionDemuxTaskInfo *    taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    PXPSURLSessionDemuxTaskInfo *    taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session dataTask:dataTask didReceiveData:data];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    PXPSURLSessionDemuxTaskInfo *    taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
        }];
    } else {
        completionHandler(proposedResponse);
    }
}

@end
