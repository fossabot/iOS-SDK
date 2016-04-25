//
//  PXPFileManager.m
//  Pods
//
//  Created by Dmitry Osipa on 1/23/16.
//
//

#import "PXPFileManager.h"
#import "PXPSDKRequestWrapper.h"
#import "PXPAccountInfo.h"
#import "PXP_Internal.h"

@interface PXPFile ()

- (instancetype)initWitnName:(NSString *)name
                        path:(NSString *)path
                        root:(NSString *)root;
+ (NSArray*)itemsFromDict:(NSDictionary *)items path:(NSString *)path root:(NSString *)root;

@end

@interface PXPFileManager ()

@property (nonatomic, strong, readwrite) PXPSDKRequestWrapper *sdkRequestWrapper;
@property (nonatomic, strong, readwrite) NSString* root;
@property (nonatomic, weak) PXPAccountInfo* info;

@end

@implementation PXPFile

- (instancetype)initWitnName:(NSString *)name
                        path:(NSString *)path
                        root:(NSString *)root
{
    self = [super init];
    if (self) {
        _name = name;
        _url = [NSString stringWithFormat:@"http://%@/%@/%@", root, path, name];
    }
    return self;
}

+ (NSArray*)itemsFromDict:(NSDictionary *)items path:(NSString *)path root:(NSString *)root {
    NSArray* images = items[@"images"];
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:images.count];
    for (NSString* imageName in images) {
        PXPFile *file = [[PXPFile alloc] initWitnName:imageName path:path root:root];
        [result addObject:file];
    }
    return result;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@: %@", [super debugDescription], self.url];
}

@end

@implementation PXPFileManager

- (instancetype)initWithAccountInfo:(PXPAccountInfo*)info {
    self = [super init];
    if (self != nil) {
        self.info = info;
    }
    return self;
}

- (PXPSDKRequestWrapper *)sdkRequestWrapper {
    return [PXP sharedSDK].wrapper;
}

- (void)setInfo:(PXPAccountInfo *)info {
    if (info != _info) {
        [_info removeObserver:self forKeyPath:NSStringFromSelector(@selector(cdnUrl)) context:nil];
        _info = info;
        [_info addObserver:self forKeyPath:NSStringFromSelector(@selector(cdnUrl)) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == _info) {
        _root = _info.cdnUrl;
    }
}

- (void)itemsAtPath:(NSString*)path
    completionBlock:(PXPFileManagerCompletionBlock)completionBlock {

    [self.sdkRequestWrapper imagesAtPath:path successBlock:^(NSURLSessionTask* task, id responseObject) {
        NSArray* result = [PXPFile itemsFromDict:responseObject path:path root:self.root];
        completionBlock(result, nil);
    } failtureBlock:^(NSURLSessionTask* task, NSError *error) {
        completionBlock(nil, error);
    }];
}

@end
