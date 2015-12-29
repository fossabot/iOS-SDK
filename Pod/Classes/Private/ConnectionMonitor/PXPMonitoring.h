//
//  PXPMonitoring.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @header  PXPMonitoring
 *  @discussion Defines PXPMonitoring protocol and PXPNetworkChangeBlock.
 */

@class PXPNetInfo;

/*!
 *  @brief block that is called on network change
 *
 *  @param netInfo object with network info and technology, or nil
 */
typedef void (^PXPNetworkChangeBlock)(PXPNetInfo* netInfo);

/*!
 *  @brief  PXPMonitoring protocol
 */
@protocol PXPMonitoring <NSObject>

/*!
 *  @brief  start cellular monitoring
 */
- (void)startMonitoring;

/*!
 *  @brief  stop network monitoring
 */
- (void)stopMonitoring;

/*!
 *  @brief  setter for network change block
 *
 *  @param block block that is called on network change
 */
- (void)setNetworkChangeBlock:(PXPNetworkChangeBlock)block;

/*!
 *  @brief  info on current network
 */
@property (atomic, strong) PXPNetInfo* currentInfo;

@end
