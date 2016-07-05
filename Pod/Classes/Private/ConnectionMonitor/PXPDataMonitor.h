//
//  PXPDataMonitor.h
//  Pods
//
//  Created by Boris Polyakov on 7/5/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PXPDataSpeed) {
    PXPDataSpeedUndefined = 0,
    PXPDataSpeedExtraLow = 20  * 1 << 10,
    PXPDataSpeedLow = 220 * 1 << 10,
    PXPDataSpeedMedium = 420 * 1 << 10,
    PXPDataSpeedHigh = 620 * 1 << 10,
    PXPDataSpeedExtraHigh = 1 * 1 << 20
};

@interface PXPDataMonitor : NSObject

@property (nonatomic, readonly) PXPDataSpeed speedType;

+ (instancetype)sharedMonitor;

@end
