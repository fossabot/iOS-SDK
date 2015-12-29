//
//  PXPWifiMonitor.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPWifiMonitor.h"
#import "PXPNetworkTechnologies.h"
#import "PXPNetInfo.h"
#import "TargetConditionals.h"

@import UIKit.UIDevice;
@import SystemConfiguration.CaptiveNetwork;

@interface UIDevice (PXPWifiSSID)

- (NSString *)currentWifiSSID;

@end

@implementation UIDevice (PXPWifiSSID)

- (NSString*)currentWifiSSID
{
    NSString* ssid = nil;
#if (TARGET_IPHONE_SIMULATOR)
    ssid = @"Simulator";
#else
    NSArray* ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString* ifnam in ifs)
    {
        NSDictionary* info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        ssid = info[(__bridge NSString*)kCNNetworkInfoKeySSID];
    }
#endif
    return ssid;
}

@end

@interface PXPWifiMonitor ()

@property (nonatomic, strong) NSTimer* wifiTimer;
@property (readwrite, nonatomic, copy) PXPNetworkChangeBlock wifiChangeBlock;

@end

@implementation PXPWifiMonitor

@synthesize currentInfo = _currentInfo;

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [self checkWifiChange];
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
    self.wifiTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkWifiChange) userInfo:nil repeats:YES];
}

- (void)stopMonitoring
{
    [self.wifiTimer invalidate];
}

- (void)setNetworkChangeBlock:(PXPNetworkChangeBlock)block
{
    self.wifiChangeBlock = block;
}

- (void)checkWifiChange
{
    PXPNetInfo* previousNetInfo = self.currentInfo;
    NSString* currentWifiSSID = [[UIDevice currentDevice] currentWifiSSID];

    PXPNetInfo* updatedInfo = (currentWifiSSID.length != 0 ? [PXPNetInfo infoWithName:currentWifiSSID
                                                                              technology:PXPNetworkWiFi] : nil);

    if (!PXPNetInfosAreEqual(updatedInfo, previousNetInfo))
    {
        self.currentInfo = updatedInfo;
        BLOCK_SAFE_RUN(self.wifiChangeBlock, self.currentInfo);
    }
}

@end
