//
//  QFLightDotView.m
//  Pixpie
//
//  Created by Dmitry Osipa on 11/18/14.
//  Copyright (c) 2014 Pixpie. All rights reserved.
//

#import "PXStatusView.h"

@interface PXStatusView ()

@property (nonatomic, strong) UIImage* redImage;
@property (nonatomic, strong) UIImage* yellowImage;
@property (nonatomic, strong) UIImage* greenImage;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) NSBundle* bundle;

@end

@implementation PXStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.state = PXStatusStateRed;
    NSString *bundlePath = [[NSBundle bundleForClass:self.class] pathForResource:@"PXStatusView" ofType:@"bundle"];
    self.bundle = [NSBundle bundleWithPath:bundlePath];
    self.redImage = [self imageNamed:@"dot_red"];
    self.greenImage = [self imageNamed:@"dot_green"];
    self.yellowImage = [self imageNamed:@"dot_yellow"];
    self.imageView = [[UIImageView alloc] initWithImage:self.redImage];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.frame = self.bounds;
    [self addSubview:self.imageView];
}

- (UIImage*)imageNamed:(NSString*)name {
    NSString* path = [self.bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (void)setState:(PXStatusState)state
{
    if (_state != state)
    {
        _state = state;
        [self updateStateImage:state];
    }
}

- (void)updateStateImage:(PXStatusState)newState
{
    switch (newState)
    {
        case PXStatusStateGreen:
        {
            self.imageView.image = self.greenImage;
            break;
        }
        case PXStatusStateYellow:
        {
            self.imageView.image = self.yellowImage;
            break;
        }
        default:
        {
            self.imageView.image = self.redImage;
            break;
        }
    }
}

@end
