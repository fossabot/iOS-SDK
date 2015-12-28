//
//  PXPAccountInfo.m
//  Pods
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import "PXPAccountInfo.h"
#import "NSObject+SafeKVC.h"

@interface PXPAccountInfo ()

@property (nonatomic, readwrite, strong) NSString* authToken;
@property (nonatomic, readwrite, strong) NSString* cdnUrl;
@property (nonatomic, strong, readwrite) PXPAuthPrincipal* principal;

@end

@implementation PXPAccountInfo

- (instancetype)initWithDict:(NSDictionary*)dict principal:(PXPAuthPrincipal*)principal {
    self = [super init];
    if (self != nil) {
        [self setIfExistsValuesForKeysWithDictionary:dict];
        _principal = principal;
    }
    return self;
}

@end
