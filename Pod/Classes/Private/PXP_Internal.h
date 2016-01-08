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

@interface PXP ()

@property (nonatomic, strong) PXPAccountInfo* accountInfo;
@property (nonatomic, strong) PXPImageTaskManager* imageTaskManager;

@end
