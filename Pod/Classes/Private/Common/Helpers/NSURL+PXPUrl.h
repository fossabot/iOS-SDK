//
//  NSURL+PXPUrl.h
//  Pods
//
//  Created by Dmitry Osipa on 3/29/16.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    PXPUrlTypeOther,
    PXPUrlTypePath,
    PXPUrlTypeCDN,
    PXPUrlTypeRemote
} PXPUrlType;

@interface NSURL (PXPUrl)

- (PXPUrlType)pxp_URLType;
- (NSString*)pathAndQuery;

@end

@interface NSString (PXPUrlTypes)

- (PXPUrlType)pxp_URLType;

@end
