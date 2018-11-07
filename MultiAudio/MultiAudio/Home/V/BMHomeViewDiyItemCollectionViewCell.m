//
//  BMHomeViewDiyItemCollectionViewCell.m
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import "BMHomeViewDiyItemCollectionViewCell.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "BMHomePlayEffectHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WaveSchedule.h"
#import <Masonry.h>
#import <BMPrivatePodsHeader.h>
#define BM_CLAM_FONT(v) [UIFont systemFontOfSize:(v)]
#define BM_CLAM_BOLD_FONT(v) [UIFont boldSystemFontOfSize:(v)]

@interface BMHomeViewDiyItemCollectionViewCell ()<UIGestureRecognizerDelegate>
/** 图标 */
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) WaveSchedule *waveView;
@property (nonatomic, strong) UIImageView *imageView;


/** 图标 */
@property (nonatomic, strong) UILabel *nameLabel;

// 音效添加成功失败 ，移除成功回调
@property (nonatomic, copy) BMHomeViewDiyItemAddSuccess addSuccesBlock;
@property (nonatomic, copy) BMHomeViewDiyItemAddFail addFaillBlock;
@property (nonatomic, copy) BMHomeViewDiyItemRemoveSuccess removeSuccesBlock;

@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation BMHomeViewDiyItemCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)  {
        [self setupUI];
        [self addGestureRecognizer];
        _volume = kBMWaveScheduleDefault;
    }
    return self;
}


- (void)setupUI {
    self.contentView.clipsToBounds = YES;
    [self.contentView addSubview:self.iconButton];
    [self.iconButton.imageView addSubview:self.waveView];
    [self.contentView addSubview:self.nameLabel];
    [self.iconButton addSubview:self.imageView];
    
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_width);
    }];
    [self.waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.iconButton.center);
    }];
    [self layoutIfNeeded];
    _waveView.layer.cornerRadius = self.iconButton.imageView.image.size.width/2;
    _waveView.layer.masksToBounds = YES;
}
- (void)addGestureRecognizer {
    UITapGestureRecognizer *tapGesturRecognizer= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tapGesturRecognizer];
    
    
}

- (void)panGestureDown:(UIPanGestureRecognizer *)pan {
    CGPoint veloctyPoint = [pan velocityInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:{
            self.volume -= veloctyPoint.y / 10000;
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if (self.volume <= 0.05) {
                // 当值为0 并且停止手势，模拟点击（只有选中状态才有手势，模拟点击关闭选中）。
                [self tapAction];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark ——— 外部
- (void)updateClickedItemAddSuccess:(BMHomeViewDiyItemAddSuccess)addSuccess addFail:(BMHomeViewDiyItemAddFail)addFail removeSuccess:(BMHomeViewDiyItemRemoveSuccess )removeSuccess {
    self.addSuccesBlock = addSuccess;
    self.addFaillBlock = addFail;
    self.removeSuccesBlock = removeSuccess;
}
#pragma mark ——— 点击
- (void)tapAction{
    BOOL selected = !self.iconButton.selected;
    BOOL showAnimate = YES;
    if (!selected) {
        [[BMHomePlayEffectHelper sharedInstance] removePlayEffect:self.model];
        if (self.removeSuccesBlock) {
            self.removeSuccesBlock(self.model);
        }
    }else {
        if (![[BMHomePlayEffectHelper sharedInstance] addPlayEffect:self.model]) {
            NSLog(@"添加失败");
            selected = !selected;
            showAnimate = NO;
            if (self.addFaillBlock) {
                self.addFaillBlock(self.model);
            }
        }else {
            if (self.addSuccesBlock) {
                self.addSuccesBlock(self.model);
            }
        }
    }
    self.iconButton.selected = selected;
    // 点击动画及震动
    if (showAnimate) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
            [generator prepare];
            [generator impactOccurred];
        }
        self.iconButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.iconButton.transform = CGAffineTransformIdentity;
        } completion:nil];
    }else {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
            [generator prepare];
            [generator impactOccurred];
        }
    }
    // 添加水波
    if (self.iconButton.selected == YES) {
        [self showWaveView:@(kBMWaveScheduleDefault)];
    }else {
        self.waveView.hidden = YES;
        [self removeGestureRecognizer:self.panGesture];
    }
}
- (void)showWaveView:(NSNumber *)volume {
    self.waveView.hidden = NO;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDown:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    [self.waveView updateViewGradientFromColor:[UIColor bm_colorWithHexString:self.model.bgFromColor] toColor:[UIColor bm_colorWithHexString:self.model.bgToColor] withRange:self.iconButton.imageView.image.size.width];
    [self.waveView showDripAnmin:volume];
}

#pragma mark ——— setter and getter

- (void)setModel:(BMHomeDiyItem *)model {
    _model = model;
    self.nameLabel.text = model.name;
    self.imageView.image = [UIImage imageNamed:BMString(model.imageName,@"_icon_select", nil)];
    // 设置选中状态
    BOOL hasModel = NO;
    for (BMHomeDiyItem *item in [BMHomePlayEffectHelper sharedInstance].playEffectArray) {
        if ([item isEqual:model]) {
            hasModel = YES;
            [self showWaveView:@(item.volume)];
            _volume = item.volume;
        }
        self.iconButton.selected = hasModel;
    }
}

- (UIButton *)iconButton {
    if (!_iconButton) {
        UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        iconButton.userInteractionEnabled = NO;
        iconButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconButton = iconButton;
        [iconButton setImage:[UIImage imageNamed:@"circle_bg"] forState:UIControlStateNormal];
    }
    return _iconButton;
}
- (WaveSchedule *)waveView {
    if (!_waveView) {
        _waveView = [WaveSchedule new];
        _waveView.backgroundColor = [UIColor clearColor];
        _waveView.hidden = YES;
    }
    return _waveView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"River";
        _nameLabel.font = BM_CLAM_FONT(15);
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}
- (void)setVolume:(CGFloat)volume {
    NSLog(@"%f---%@",volume,self.panGesture);
    if (volume>=0 && volume<=1) {
        _volume = volume;
        self.model.volume = volume;
        [_waveView drawWaterWavePath:@(volume)];
        [[BMHomePlayEffectHelper sharedInstance] setVolume:volume WithEffect:self.model];
    }
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}
@end
