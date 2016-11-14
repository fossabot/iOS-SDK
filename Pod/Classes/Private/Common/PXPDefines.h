//
//  PXPDefines.h
//  Pixpie
//
//  Created by Dmitry Osipa on 12/29/15.
//
//

#ifndef PXPDefines_h
#define PXPDefines_h

#define PXP_CONCAT(x,y,z) x y z
#define PXP_IDENTIFY(name) PXP_CONCAT(PIXPIE_IDENTIFIER, ".", name)
#define PXP_IDENTIFY_IN_RUNTIME(name) ([NSString stringWithFormat:@"%@.%@", @PIXPIE_IDENTIFIER, name])
#define PXP_IDENTIFY_CLASS(class) (PXP_IDENTIFY_IN_RUNTIME(NSStringFromClass(class)))

#define CONDITIONAL_SET_OBJECT(dictionary, key, value, condition) if (condition)[dictionary setObject:value forKey:key]
#define SAFE_ADD_OBJECT(mutableArray, value) if (nil != value) [mutableArray addObject:value]
#define SAFE_SET_OBJECT(dictionary, key, value) if (nil != value)[dictionary setObject:value forKey:key]
#define SAFE_GET_OBJECT(dictionary, key) ([[dictionary objectForKey:key] isEqual:[NSNull null]]?nil:[dictionary objectForKey:key])
#define BLOCK_SAFE_RUN(block, ...) do{ block ? block(__VA_ARGS__) : nil; }while(0)
#define SAFE_ADD_OBJECT(mutableArray, value) if (nil != value) [mutableArray addObject:value]

#define DEBUG_LEVEL_MASK (DEBUG_ERROR | DEBUG_WARN | DEBUG_INFO | DEBUG_VERBOSE)

#define DEBUG_ERROR     (1 << 0)
#define DEBUG_WARN      (1 << 1)
#define DEBUG_INFO      (1 << 2)
#define DEBUG_VERBOSE   (1 << 4)

#if DEBUG
#define PXPLog(fmt, ...)            do{                                NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}while(0)

#define PXPLogError(fmt, ...)     do{ if(DEBUG_LEVEL_MASK & DEBUG_ERROR)    NSLog((@"[ERROR] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}while(0)
#define PXPLogWarn(fmt, ...)      do{ if(DEBUG_LEVEL_MASK & DEBUG_WARN)    NSLog((@"[WARN] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}while(0)
#define PXPLogInfo(fmt, ...)      do{ if(DEBUG_LEVEL_MASK & DEBUG_INFO)    NSLog((@"[INFO] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}while(0)
#define PXPLogVerbose(fmt, ...)   do{ if(DEBUG_LEVEL_MASK & DEBUG_VERBOSE)    NSLog((@"[VERB] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}while(0)

#define PXPConditionalLog(condition, ...) do{ if ( !(condition) ) NSLog(__VA_ARGS__); }while(0)
#else

#define PXPLog(...)
#define PXPLogError(...)
#define PXPLogWarn(...)
#define PXPLogInfo(...)
#define PXPLogVerbose(...)

#define PXPConditionalLog(...)
#endif

#endif /* PXPDefines_h */
