//
//  PXPConfig.m
//  Pods
//
//  Created by Dmitry Osipa on 4/3/16.
//
//

#import "PXPConfig.h"

static NSString* const kPXPPlistName = @"Pixpie-Info";

static NSString* const kPXPAppSecretKey = @"PXPAppSecretKey";
static NSString* const kPXPBackendUrlKey = @"PXPBackendUrl";
static NSString* const kPXPRequestSaltKey = @"PXPRequestSalt";
static NSString* const kPXPAppId = @"PXPAppId";

//@"http://api.pixpie.co:9001"
//PIXPIE_SALT_VERY_SECURE

@interface PXPConfig ()

@property (nonatomic, strong) NSDictionary* config;

@end

@implementation PXPConfig

+ (instancetype)defaultConfig {
    static PXPConfig *_sharedConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfig = [[PXPConfig alloc] initWithPlistName:kPXPPlistName];
    });

    return _sharedConfig;
}

- (instancetype)initWithPlistName:(NSString *)plistName
{
    self = [super init];
    if (self != nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        NSAssert(path.length, @"Pixpie-Info.plist is missing");
        _config =  [NSDictionary dictionaryWithContentsOfFile:path];
        NSAssert(_config, @"Pixpie-Info.plist is invalid");
    }
    return self;
}

- (NSString *)backend {
    return _config[kPXPBackendUrlKey];
}

- (NSString *)appSecret {
    return _config[kPXPAppSecretKey];
}

- (NSString *)requestSalt {
    return _config[kPXPRequestSaltKey];
}

- (NSString *)appId {
    NSString * bundleId = _config[kPXPAppId];
    if (bundleId.length == 0) {
        bundleId = [NSBundle mainBundle].bundleIdentifier;
    }
    return bundleId;
}


@end
