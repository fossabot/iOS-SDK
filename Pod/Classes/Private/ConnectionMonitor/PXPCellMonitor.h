//
//  PXPCellMonitor.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 12/29/15.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXPMonitoring.h"

/*!
 *  @header  PXPCellMonitor
 *  @discussion Cell Monitor class monitors change of current cellular states(change data technology, cellular provider, etc)
 */

@interface PXPCellMonitor : NSObject <PXPMonitoring>

@end
