//
//  NSOperationQueue+PXPExtensions.m
//  Pods
//
//  Created by Dmitry Osipa on 4/15/16.
//
//

#import "NSOperationQueue+PXPExtensions.h"

@implementation NSOperationQueue (PXPExtensions)

- (NSArray<NSOperation*>* _Nullable)operationsForIdentifier:(NSString* _Nonnull)identifier {
    NSArray<NSOperation*> *allOperations = self.operations.copy;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", identifier];
    NSArray *operations = [allOperations filteredArrayUsingPredicate:predicate];
    return operations;
}

@end
