//
//  PXPModelProtocol.h
//  Pods
//
//  Created by Dmitry Osipa on 2/17/16.
//
//

#import <Foundation/Foundation.h>

extern NSString* const kPXPModelUpdatedNotification;
extern NSString* const kPXPModelUpdateErrorKey;

@protocol PXPModelProtocol <NSObject>

- (void)update;

@end

@interface PXPModelObject : NSObject <PXPModelProtocol>

@end
