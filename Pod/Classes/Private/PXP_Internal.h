//
//  PXP_Internal.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXP.h"

@class PXPAccountInfo;
@class PXPImageTaskManager;

@interface PXP (Internal)

@property (nonatomic, strong, readonly) PXPImageTaskManager* imageTaskManager;
@property (nonatomic, strong, readonly) PXPAccountInfo *accountInfo;

@end
