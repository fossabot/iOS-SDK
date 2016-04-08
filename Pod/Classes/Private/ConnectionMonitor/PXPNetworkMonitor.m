//
//  PXPNetworkMonitor.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPNetworkMonitor.h"
#import "PXPCellMonitor.h"
#import "PXPWifiMonitor.h"
#import "PXPNetInfo.h"
#import "PXPNetworkTechnologies.h"
@import UIKit.UIDevice;
#import <AFNetworking/AFNetworkReachabilityManager.h>

NSString* const kPXPNetworkChangedNotification = @"kPXPNetworkChangedNotification";

@interface PXPNetworkMonitor ()

@property (nonatomic, strong) AFNetworkReachabilityManager* reachabilityManager;
@property (nonatomic, strong) PXPCellMonitor* cellMonitor;
@property (nonatomic, strong) PXPWifiMonitor* wifiMonitor;
@property (nonatomic, strong, readwrite) PXPNetInfo* currentNetworkTechnology;

@end

@implementation PXPNetworkMonitor

+ (instancetype)sharedMonitor {
    static PXPNetworkMonitor *_sharedMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMonitor = [PXPNetworkMonitor new];
        [_sharedMonitor startMonitoring];
    });

    return _sharedMonitor;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        self.cellMonitor = [PXPCellMonitor new];
        self.wifiMonitor = [PXPWifiMonitor new];
        self.currentNetworkTechnology = (self.currentWifiInfo != nil ? self.currentWifiInfo : self.currentCellInfo);
    }
    return self;
}

- (void)dealloc
{
    [self stopMonitoring];
}

- (void)startMonitoring
{
    [self stopMonitoring];
    __weak typeof(self)weakSelf = self;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf reachabilityStatusChanged:status];
    }];
    [self.cellMonitor setNetworkChangeBlock:^(PXPNetInfo *netInfo) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.reachabilityManager isReachableViaWWAN])
        {
            strongSelf.currentNetworkTechnology = netInfo;
        }
    }];
    [self.wifiMonitor setNetworkChangeBlock:^(PXPNetInfo *netInfo) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.reachabilityManager isReachableViaWiFi])
        {
            strongSelf.currentNetworkTechnology = netInfo;
        }
    }];
    [self.reachabilityManager startMonitoring];
    [self.wifiMonitor startMonitoring];
    [self.cellMonitor startMonitoring];
}

- (void)stopMonitoring
{
    [self.reachabilityManager stopMonitoring];
    [self.wifiMonitor stopMonitoring];
    [self.cellMonitor stopMonitoring];
    self.currentNetworkTechnology = nil;
}

- (void)reachabilityStatusChanged:(AFNetworkReachabilityStatus)status
{
    PXPNetInfo* currentNetInfo = nil;
    if (AFNetworkReachabilityStatusReachableViaWiFi == status)
    {
        currentNetInfo = self.currentWifiInfo;
    }
    else if (AFNetworkReachabilityStatusReachableViaWWAN == status)
    {
        currentNetInfo = self.currentCellInfo;
    }
    else if (AFNetworkReachabilityStatusUnknown == status)
    {
        currentNetInfo = (self.currentWifiInfo != nil ? self.currentWifiInfo : self.currentCellInfo);
    }
    else
    {
        currentNetInfo = nil;
    }
    self.currentNetworkTechnology = currentNetInfo;
}

- (void)setCurrentNetworkTechnology:(PXPNetInfo*)networkTechnology
{
    BOOL isNewTechnologyEqualToOld = NO;

    if (_currentNetworkTechnology != nil && networkTechnology != nil)
    {
        isNewTechnologyEqualToOld = [_currentNetworkTechnology isEqualToNetInfo:networkTechnology];
    }
    else
    {
        isNewTechnologyEqualToOld = NO;
    }

    if (!isNewTechnologyEqualToOld)
    {
        _currentNetworkTechnology = networkTechnology;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kPXPNetworkChangedNotification object:self];
        });
    }
}

- (PXPNetInfo*)currentCellInfo
{
    return self.cellMonitor.currentInfo;
}

- (PXPNetInfo*)currentWifiInfo
{
    return self.wifiMonitor.currentInfo;
}

@end
