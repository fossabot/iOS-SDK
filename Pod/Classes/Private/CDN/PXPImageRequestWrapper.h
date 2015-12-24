//
//  PXPImageRequestWrapper.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

#import <Foundation/Foundation.h>

typedef void (^PXPImageRequestCompletionBlock)(UIImage* responseObject, NSError* error);

@interface PXPImageRequestWrapper : NSObject

- (NSURLSessionDataTask *)imageTaskForUrl:(NSURL *)url
                               completion:(PXPImageRequestCompletionBlock)completionBlock;

@end
