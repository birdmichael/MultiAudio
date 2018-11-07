//
//  BMHomePlayEffectHelper.h
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMHomeDiyItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface BMHomePlayEffectHelper : NSObject

@property (nonatomic, strong ,readonly) NSArray *playEffectArray;

+ (instancetype)sharedInstance;

// 添加音效，每次添加音效自动播放。（播放所有音效和Diy cell选中状态双向绑定）
- (BOOL)addPlayEffect:(BMHomeDiyItem *)item;
- (BOOL)removePlayEffect:(BMHomeDiyItem *)item;
- (void)removeAllPlayEffects;
- (void)setAllVolumeMute:(BOOL)isMute;
- (void)setVolume:(CGFloat)volume WithEffect:(BMHomeDiyItem *)item;

@end

NS_ASSUME_NONNULL_END
