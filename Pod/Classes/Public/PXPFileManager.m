//
//  PXPFileManager.m
//  Pods
//
//  Created by Dmitry Osipa on 1/23/16.
//
//

#import "PXPFileManager.h"
#import "PXPSDKRequestWrapper.h"

@interface PXPFile ()

- (instancetype)initWitnName:(NSString *)name
                        path:(NSString *)path
                        root:(NSString *)root;
+ (NSArray*)itemsFromDict:(NSDictionary *)items path:(NSString *)path root:(NSString *)root;

@end

@interface PXPFileManager ()

@property (nonatomic, strong, readwrite) PXPSDKRequestWrapper *sdkRequestWrapper;
@property (nonatomic, strong, readwrite) NSString* root;

@end

@implementation PXPFile

- (instancetype)initWitnName:(NSString *)name
                        path:(NSString *)path
                        root:(NSString *)root
{
    self = [super init];
    if (self) {
        _name = name;
        _url = [NSString stringWithFormat:@"%@%@%@", root, path, name];
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

@end

@implementation PXPFileManager

- (instancetype)initWithSDKRequestWrapper:(PXPSDKRequestWrapper *)sdkRequestWrapper
                                     root:(NSString *)root
{
    self = [super init];
    if (self != nil) {
        _sdkRequestWrapper = sdkRequestWrapper;
        _root = root;
    }
    return self;
}

- (void)itemsAtPath:(NSString*)path
    completionBlock:(PXPFileManagerCompletionBlock)completionBlock {

    [self.sdkRequestWrapper imagesAtPath:path successBlock:^(id responseObject) {
        NSArray* result = [PXPFile itemsFromDict:responseObject path:path root:self.root];
        completionBlock(result, nil);
    } failtureBlock:^(NSError *error) {
        completionBlock(nil, error);
    }];
}

@end
