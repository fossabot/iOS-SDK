//
//  PXPCellMonitor.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "PXPCellMonitor.h"
#import "PXPNetworkTechnologies.h"
#import "PXPNetInfo.h"
#import "PXPDefines.h"
@import CoreTelephony.CTTelephonyNetworkInfo;
@import CoreTelephony.CTCarrier;

@interface PXPCellMonitor ()

@property (readwrite, nonatomic, copy) PXPNetworkChangeBlock cellNetworkChangeBlock;
@property (nonatomic, strong) CTTelephonyNetworkInfo* telephonyInfo;

@end

@implementation PXPCellMonitor

@synthesize currentInfo = _currentInfo;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.telephonyInfo = [CTTelephonyNetworkInfo new];
        [self cellNetworkChanged];
    }
    return self;
}

- (void)dealloc
{
    [self stopMonitoring];
}

#pragma mark - Public Interface

- (void)startMonitoring
{
    [self stopMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeWWANChange:)
                                                 name:CTRadioAccessTechnologyDidChangeNotification
                                               object:nil];

    __weak typeof(self)weakSelf = self;
    self.telephonyInfo.subscriberCellularProviderDidUpdateNotifier = ^(__unused CTCarrier *carrier) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf cellNetworkChanged];
    };
}

- (void)stopMonitoring
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CTRadioAccessTechnologyDidChangeNotification
                                                  object:self.telephonyInfo];
    self.telephonyInfo.subscriberCellularProviderDidUpdateNotifier = nil;
}

- (void)setNetworkChangeBlock:(PXPNetworkChangeBlock)block
{
    self.cellNetworkChangeBlock = block;
}

#pragma mark - Notification observation

- (void)observeWWANChange:(NSNotification*)note
{
    [self cellNetworkChanged];
}

- (void)cellNetworkChanged
{
    PXPNetInfo* previousNetInfo = self.currentInfo;
    CTCarrier* carrier = self.telephonyInfo.subscriberCellularProvider;
    
    NSString* cellTechnology = self.telephonyInfo.currentRadioAccessTechnology != nil ? self.telephonyInfo.currentRadioAccessTechnology : self.currentInfo.technology;
    
    PXPNetInfo* updatedInfo = ((carrier != nil || cellTechnology != nil) ? [PXPNetInfo infoWithName:carrier.carrierName technology:cellTechnology] : nil);

    if (updatedInfo != previousNetInfo && ![updatedInfo isEqual:previousNetInfo]) {
        self.currentInfo = updatedInfo;
        BLOCK_SAFE_RUN(self.cellNetworkChangeBlock, _currentInfo);
    }
}


@end
