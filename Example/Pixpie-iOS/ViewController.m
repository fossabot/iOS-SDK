//
//  PXPViewController.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/17/2015.
//  Copyright (c) 2015 Pixpie. All rights reserved.
//

#import "ViewController.h"
@import Pixpie_iOS.UIImageView_PXPExtensions;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

//    NSURL* url = [NSURL URLWithString:@"http://dmitry-230a.kxcdn.com/edb6716253fd34059401c3e198836aa0613a4b03c7e700fd05b9630c6032193d/kotivka.jpg"];

    //NSString* path = @"kotivka.jpg";
    NSURL* url = [NSURL URLWithString:@"https://pp.vk.me/c624523/v624523339/3e6c5/NltvMvI6w6k.jpg"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self.imageView pxp_requestImageForPath:path];
        [self.imageView pxp_requestImage:url];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
