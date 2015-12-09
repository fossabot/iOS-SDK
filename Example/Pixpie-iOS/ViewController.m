//
//  PXPViewController.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/17/2015.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "ViewController.h"
@import Pixpie_iOS;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self.imageView pxp_requestImageNamed:@"lena"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
