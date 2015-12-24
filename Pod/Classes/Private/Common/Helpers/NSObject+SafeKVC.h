//
//  SafeKVC.h
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2014 Pixpie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  NSObject (SafeKVC)

- (void)setIfExistsValuesForKeysWithDictionary:(NSDictionary*)dictionary;

@end
