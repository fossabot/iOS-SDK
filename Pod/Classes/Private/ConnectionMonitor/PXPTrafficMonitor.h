//
//  PXPTrafficMonitor.h
//  Pods
//
//  Created by Boris Polyakov on 7/7/16.
//
//

#import <Foundation/Foundation.h>

@interface PXPTrafficMonitor : NSObject

+ (instancetype)sharedMonitor;

@property (nonatomic, readonly) NSUInteger totalBytesForSession;
@property (nonatomic, readonly) NSArray *dataSamples;

@end
