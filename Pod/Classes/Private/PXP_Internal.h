//
//  PXP_Internal.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import "PXP.h"

@class PXPAccountInfo;
@class PXPImageDownloader;

@interface PXP ()

@property (nonatomic, strong) PXPAccountInfo* accountInfo;
@property (nonatomic, strong) PXPImageDownloader* imageDownloader;

@end
