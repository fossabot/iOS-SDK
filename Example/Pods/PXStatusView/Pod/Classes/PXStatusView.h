//
//  QFLightDotView.h
//  Pixpie
//
//  Created by Dmitry Osipa on 11/18/14.
//  Copyright (c) 2014 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PXStatusState){
    PXStatusStateGreen,
    PXStatusStateYellow,
    PXStatusStateRed
};

@interface PXStatusView : UIView

@property (nonatomic, assign) PXStatusState state;

@end
