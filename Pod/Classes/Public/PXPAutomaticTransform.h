//
//  PXPAutomaticTransform.h
//  Pods
//
//  Created by Dmitry Osipa on 9/12/16.
//
//

#import <Pixpie/Pixpie.h>

NS_ASSUME_NONNULL_BEGIN

@interface PXPAutomaticTransform : PXPTransform

- (instancetype)initWithImageView:(UIImageView* _Nullable)contextView originUrl:(NSString* _Nullable)url;
@property (nonatomic, weak, nullable) UIImageView* contextView;

@end

NS_ASSUME_NONNULL_END
