//
//  PXPAccountInfo.h
//  Pods
//
//  Created by Dmitry Osipa on 10/26/15.
//
//

#import <Foundation/Foundation.h>

@interface PXPAccountInfo : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDict:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSString* authToken;

@end
