//
//  PXPTask.h
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PXPTaskStateStopped,
    PXPTaskStateInProgress,
    PXPTaskStateComplete
} PXPTaskState;

NS_ASSUME_NONNULL_BEGIN

@interface PXPTask : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL*)url;
- (void)cancel;

@property (nonatomic, readonly) PXPTaskState state;

@end

NS_ASSUME_NONNULL_END
