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

@end

@implementation PXPAccountInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self != nil) {
        [self setIfExistsValuesForKeysWithDictionary:dict];
    }
    return self;
}

@end
