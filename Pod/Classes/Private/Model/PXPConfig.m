//
//  PXPConfig.m
//  Pods
//
//  Created by Dmitry Osipa on 4/3/16.
//
//

#import "PXPConfig.h"
#include <sys/sysctl.h>

static NSString* const kPXPPlistName = @"Pixpie-Info";

static NSString* const kPXPAppSecretKey = @"PXPAppSecretKey";
static NSString* const kPXPBackendUrlKey = @"PXPBackendUrl";
static NSString* const kPXPRequestSaltKey = @"PXPRequestSalt";
static NSString* const kPXPAppId = @"PXPAppId";
static NSInteger const kPXPSDKTypeiOS = 1;

@interface PXPConfig ()

@property (nonatomic, strong) NSDictionary* config;
@property (nonatomic, readwrite, strong) NSString* deviceDescription;

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
        _config =  [NSDictionary dictionaryWithContentsOfFile:path];
        _clientSdkType = @(kPXPSDKTypeiOS);
        _deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
        _deviceDescription = [PXPConfig hardwareString];
        _sdkVersion = @PIXPIE_VERSION;
    }
    return self;
}

- (NSString *)backend {
    NSString* result = _config[kPXPBackendUrlKey];
    if (result.length == 0) {
        result =  @PIXPIE_URL;
    }
    return result;
}

- (NSString *)requestSalt {
    NSString* result = _config[kPXPRequestSaltKey];
    if (result.length == 0) {
        result =  @PIXPIE_MAGIC_KEY;
    }
    return result;
}

- (NSString *)appId {
    NSString * bundleId = _config[kPXPAppId];
    if (bundleId.length == 0) {
        bundleId = [NSBundle mainBundle].bundleIdentifier;
    }
    return bundleId;
}

- (NSString*)deviceDescription {
    if (_deviceDescription == nil) {
        _deviceDescription = [PXPConfig hardwareString];
    }
    return _deviceDescription;
}

#pragma mark - Class Methods

+ (NSString*)hardwareString {
    int name[] = {CTL_HW,HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
    char *hw_machine = malloc(size);

    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = @(hw_machine);
    free(hw_machine);
    return hardware;
}


@end
