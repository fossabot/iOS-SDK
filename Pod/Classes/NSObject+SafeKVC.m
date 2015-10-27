//
//  SafeKVC.m
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 10/26/15.
//  Copyright (c) 2014 Pixpie. All rights reserved.
//

#import "NSObject+SafeKVC.h"

@implementation NSObject (SafeKVC)

- (void)setIfExistsValuesForKeysWithDictionary:(NSDictionary*)dictionary
{
    NSArray* keys = dictionary.allKeys;
    for (NSString* key in keys)
    {
        SEL selector = NSSelectorFromString(key);
        if ([self respondsToSelector:selector])
        {
            id value = dictionary[key];
            [self setValue:value forKey:key];
        }
    }
}

@end
