//
//  BMHomeVIewDiyItemContetNode.h
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "BMHomeDiyItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface BMHomeVIewDiyItemContetNode : ASDisplayNode

- (instancetype)initWithDataArray:(NSArray<BMHomeDiyItem *> *)dataArray;


- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithViewBlock:(ASDisplayNodeViewBlock)viewBlock NS_UNAVAILABLE;
- (instancetype)initWithLayerBlock:(ASDisplayNodeLayerBlock)layerBlock NS_UNAVAILABLE;
- (instancetype)initWithViewBlock:(ASDisplayNodeViewBlock)viewBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock NS_UNAVAILABLE;
- (instancetype)initWithLayerBlock:(ASDisplayNodeLayerBlock)layerBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
