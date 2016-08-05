//
//  PXPNetInfo.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTTelephonyNetworkInfo;
@class PXPNetInfo;

/*!
 *  @header PXPNetInfo
 *  @discussion  class for storing network related info
 */

/*!
 *  @brief method to compare net infos
 *
 *  @param firstNetInfo first info to compare
 *  @param secondNetInfo second info to compare
 *
 *  @return YES, if infos are equal
 */
BOOL PXPNetInfosAreEqual(PXPNetInfo* firstNetInfo, PXPNetInfo* secondNetInfo);

/*!
 *  @brief  class for storing network related info
 */
@interface PXPNetInfo : NSObject

/*!
 *  @brief  default initializer
 *
 *  @param name       current network name
 *  @param technology current network technology
 *
 *  @return initialized object
 */
+ (instancetype)infoWithName:(NSString*)name technology:(NSString*)technology;

/*!
 *  @brief initializer for carriers
 *
 *  @param telephonyInfo telephony info
 *
 *  @return initialized object
 */
+ (instancetype)infoWithTelephonyNetworkInfo:(CTTelephonyNetworkInfo*)telephonyInfo;

/*!
 *  @brief  method for checking is this wifi network
 *
 *  @return YES if wifi, NO otherwise
 */
- (BOOL)isWifi;

/*!
 *  @brief  method for checking is this cell network
 *
 *  @return YES if cell, NO otherwise
 */
- (BOOL)isCell;

/*!
 *  @brief  method for checking is this unknown network
 *
 *  @return YES if unknown, NO otherwise
 */
- (BOOL)isUnknown;

/*!
 *  @brief  checks equality of two NetInfo objects. Objects are equal if name and technology are equal
 *
 *  @param other other NetInfo object
 *
 *  @return YES if equal, NO otherwise
 */
- (BOOL)isEqualToNetInfo:(PXPNetInfo*)other;

/*!
 *  @brief  network name
 */
@property (nonatomic, strong, readonly) NSString* name;

/*!
 *  @brief  network technology
 */
@property (nonatomic, strong, readonly) NSString* technology;

/*!
 *  @brief additional network info
 */
@property (nonatomic, strong, readonly) id networkInfo;

@end
