//
//  PXPTask.m
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import "PXPTask.h"

@interface PXPTask ()

@property (nonatomic, strong) NSURL* url; // task identifier

@end

@implementation PXPTask

- (instancetype)initWithURL:(NSURL*)url {
    self = [super init];
    if (self != nil) {
        _url = url;
    }
}

- (void)executeRequest:(NSURLRequest*)request {
    
}

- (void)cancel {

}

@end
