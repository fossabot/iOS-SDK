//
//  PXPWebPResponseSerializer.h
//  Pods
//
//  Created by Dmitry Osipa on 12/13/15.
//
//

@import AFNetworking;

NS_ASSUME_NONNULL_BEGIN

@interface PXPWebPResponseSerializer : AFHTTPResponseSerializer <AFURLResponseSerialization>

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

NS_ASSUME_NONNULL_END
