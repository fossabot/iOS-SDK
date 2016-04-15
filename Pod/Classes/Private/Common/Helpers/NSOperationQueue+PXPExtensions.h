//
//  NSOperationQueue+PXPExtensions.h
//  Pods
//
//  Created by Dmitry Osipa on 4/15/16.
//
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (PXPExtensions)

- (NSArray<NSOperation*>* _Nullable)operationsForIdentifier:(NSString* _Nonnull)identifier;

@end
