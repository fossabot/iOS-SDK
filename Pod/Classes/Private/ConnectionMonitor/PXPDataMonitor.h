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
    PXPDataSpeedExtraLow,
    PXPDataSpeedLow,
    PXPDataSpeedMedium,
    PXPDataSpeedHigh,
    PXPDataSpeedExtraHigh,
    PXPDataSpeedIdle,
    PXPDataSpeedNone
};

static NSString* const kPXPSpeedChanged;

@interface PXPDataMonitor : NSObject

@property (atomic, readonly, assign) PXPDataSpeed speedType;

+ (instancetype)sharedMonitor;

@end
