//
//  PXPFileManager.h
//  Pods
//
//  Created by Dmitry Osipa on 1/23/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PXPFile;

typedef void(^PXPFileManagerCompletionBlock)(NSArray <PXPFile *> * _Nullable items, NSError * _Nullable error);

@interface PXPFile : NSObject

- (instancetype)init NS_UNAVAILABLE;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* url;

@end

@interface PXPFileManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (void)itemsAtPath:(NSString*)path
    completionBlock:(PXPFileManagerCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
