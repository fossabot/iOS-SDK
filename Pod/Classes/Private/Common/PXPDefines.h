//
//  PXPDefines.h
//  Pods
//
//  Created by Dmitry Osipa on 12/29/15.
//
//

#ifndef PXPDefines_h
#define PXPDefines_h

#define CONDITIONAL_SET_OBJECT(dictionary, key, value, condition) if (condition)[dictionary setObject:value forKey:key]
#define SAFE_ADD_OBJECT(mutableArray, value) if (nil != value) [mutableArray addObject:value]
#define SAFE_SET_OBJECT(dictionary, key, value) if (nil != value)[dictionary setObject:value forKey:key]
#define SAFE_GET_OBJECT(dictionary, key) ([[dictionary objectForKey:key] isEqual:[NSNull null]]?nil:[dictionary objectForKey:key])
#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

#endif /* PXPDefines_h */
