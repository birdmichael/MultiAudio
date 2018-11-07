//
//  WaveSchedule.h
//  Calm
//
//  Created by BirdMichael on 2018/10/31.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
static const CGFloat kBMWaveScheduleDefault = 0.6;

@interface WaveSchedule : UIView
// 请先设置颜色然后修改中值
- (void)updateViewGradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withRange:(int)range;
- (void)drawWaterWavePath:(NSNumber *)percent;
//- (void)splashWater;
- (void)showDripAnmin:(NSNumber *)percent;
@end

NS_ASSUME_NONNULL_END
