//
//  PXPNetworkMonitor.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @header PXPNetworkMonitor
 *  @discussion Class monitors change of current cellular and wifi networks(change of data technology, cellular provider, wifi network, etc)
 */

@class PXPNetInfo;

/*!
 *  @brief  Notification that is called on network change
 */
extern NSString* const kPXPNetworkChangedNotification;

/*!
 *  @brief  Class monitors change of current cellular and wifi networks
 */
@interface PXPNetworkMonitor : NSObject

/*!
 *  @brief  singleton for monitor
 *
 *  @return initialized monitor with started monitoring(no need to call -startMonitoring)
 */
+ (instancetype)sharedMonitor;

/*!
 *  @brief  start network monitoring
 */
- (void)startMonitoring;

/*!
 *  @brief  stop network monitoring
 */
- (void)stopMonitoring;

/*!
 *  @brief  current network(cell or wifi). If connected to internet and Wifi is enabled will return current wifi network. May be nil
 */
@property (nonatomic, strong, readonly) PXPNetInfo* currentNetworkTechnology;

/*!
 *  @brief  current cellular network. May be nil
 */
@property (nonatomic, strong, readonly) PXPNetInfo* currentCellInfo;
/*!
 *  @brief  current wifi network. May be nil
 */
@property (nonatomic, strong, readonly) PXPNetInfo* currentWifiInfo;

@end
