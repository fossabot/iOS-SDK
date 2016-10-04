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
- (void)reset;

@property (nonatomic, readonly) NSArray *dataSamples;
@property (nonatomic, readonly) NSNumber *lastSample;
@property (nonatomic, assign, readonly) NSUInteger totalBytes;

@end
