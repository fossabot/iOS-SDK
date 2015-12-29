//
//  PXPNetInfo.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPNetInfo.h"
#import "PXPNetworkTechnologies.h"
@import CoreTelephony.CTTelephonyNetworkInfo;
@import CoreTelephony.CTCarrier;

BOOL PXPNetInfosAreEqual(PXPNetInfo* firstNetInfo, PXPNetInfo* secondNetInfo) {
    BOOL isEqualToInfo = NO;
    if (firstNetInfo != nil && secondNetInfo != nil)
    {
        isEqualToInfo = [firstNetInfo isEqualToNetInfo:secondNetInfo];
    }
    else
    {
        isEqualToInfo = NO;
    }
    return isEqualToInfo;
}



@interface PXPNetInfo ()

- (instancetype)initWithName:(NSString*)name technology:(NSString*)technology;

@property (nonatomic, strong, readwrite) id networkInfo;

@end

@implementation PXPNetInfo

- (instancetype)initWithName:(NSString*)name technology:(NSString*)technology
{
    self = [super init];
    if (self) {
        _technology = [PXPNetInfo networkTechnologyForCTNetworkTechnology:technology];
        _name = (name == nil ? @"N/A" : name);
    }
    return self;
}

+ (instancetype)infoWithName:(NSString *)name technology:(NSString *)technology
{
    return [[PXPNetInfo alloc] initWithName:name technology:technology];
}

+ (instancetype)infoWithTelephonyNetworkInfo:(CTTelephonyNetworkInfo*)telephonyInfo
{
    PXPNetInfo* networkInfo = [[PXPNetInfo alloc] initWithName:telephonyInfo.subscriberCellularProvider.carrierName
                                                    technology:telephonyInfo.currentRadioAccessTechnology];
    networkInfo.networkInfo = telephonyInfo;
    return networkInfo;
}

- (BOOL)isWifi
{
    return ([self.technology isEqualToString:PXPNetworkWiFi]);
}

- (BOOL)isCell
{
    return (![self isWifi] &&
            ![self isUnknown]);
}

- (BOOL)isUnknown
{
    return ([self.technology isEqualToString:PXPNetworkUnknown]);
}

- (NSString*)debugDescription
{
    return [NSString stringWithFormat:@"%@ {Name:%@ Technology:%@}", self, self.name, self.technology];
}

#pragma mark - Overrides

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToNetInfo:other];
}

- (BOOL)isEqualToNetInfo:(PXPNetInfo*)other
{
    BOOL equalNames = [self.name isEqualToString:other.name];
    BOOL equalTechnologies = [self.technology isEqualToString:other.technology];
    return (equalNames && equalTechnologies);
}

#pragma mark - Class methods

+ (NSDictionary*)networkTechnologies
{
    static NSDictionary* sPXPNetworkTechnologies = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPXPNetworkTechnologies = @{ CTRadioAccessTechnologyCDMAEVDORevB : PXPNetworkCDMAEVDORevB,
                                     CTRadioAccessTechnologyCDMAEVDORevA : PXPNetworkCDMAEVDORevA,
                                     CTRadioAccessTechnologyCDMAEVDORev0 : PXPNetworkCDMAEVDORev0,
                                     CTRadioAccessTechnologyCDMA1x: PXPNetworkCDMA1x,
                                     CTRadioAccessTechnologyWCDMA : PXPNetworkWCDMA,
                                     CTRadioAccessTechnologyHSUPA : PXPNetworkHSUPA,
                                     CTRadioAccessTechnologyHSDPA : PXPNetworkHSDPA,
                                     CTRadioAccessTechnologyeHRPD : PXPNetworkeHRPD,
                                     CTRadioAccessTechnologyGPRS : PXPNetworkGPRS,
                                     CTRadioAccessTechnologyEdge : PXPNetworkEdge,
                                     CTRadioAccessTechnologyLTE : PXPNetworkLTE,
                                     PXPNetworkWiFi : PXPNetworkWiFi};
    });
    return sPXPNetworkTechnologies;
}

+ (NSString*)networkTechnologyForCTNetworkTechnology:(NSString*)technology
{
    NSDictionary* networkTechnologies = [PXPNetInfo networkTechnologies];
    NSString* networkType = nil;
    if (technology.length > 0)
    {
        networkType = networkTechnologies[technology];
        if (networkType.length == 0)
        {
            networkType = PXPNetworkUnknown;
        }
    }
    return networkType;
}

@end

