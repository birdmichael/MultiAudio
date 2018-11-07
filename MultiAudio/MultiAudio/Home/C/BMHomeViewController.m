//
//  BMHomeViewController.m
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//
#import <Masonry.h>
#import "BMHomeViewController.h"
#import "BMHomeViewDiyView.h"
#import "AppDelegate.h"
#import "BMHomePlayEffectHelper.h"
#import <BMPrivatePodsHeader.h>

@interface BMHomeViewController ()
@property (nonatomic, weak) BMHomeViewDiyView *diyView;
@property (nonatomic, weak) UIButton *mute;
@end

@implementation BMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeBg"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    [self addTopBtn];

}

#pragma mark ——— 私有方法
- (void)addTopBtn {
    UIButton *diyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [diyBtn setImage:[UIImage imageNamed:@"DIY"] forState:UIControlStateNormal];
    [self.view addSubview:diyBtn];
    [diyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(33 + kBMStatusBarHeight);
        make.right.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    diyBtn.bm_touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    __weak __typeof(self)weakSelf = self;
    [diyBtn bm_touchUpInside:^{
        [weakSelf diyBtnClicked];
    }];
    
    
    UIButton *mute = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:mute];
    [mute setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateSelected];
    [mute setImage:[UIImage imageNamed:@"sound"] forState:UIControlStateNormal];
    [mute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(diyBtn);
        make.right.equalTo(diyBtn.mas_left).offset(-30);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    mute.bm_touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [mute bm_touchUpInside:^{
        [weakSelf muteBtnClicked:mute];
    }];
    self.mute = mute;
    
    UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:more];
    [more setImage:[UIImage imageNamed:@"setting_icon"] forState:UIControlStateNormal];
    [more mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(diyBtn);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    more.bm_touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [more bm_touchUpInside:^{
        [weakSelf moreBtnClicked];
    }];
}
#pragma mark ———  action
- (void)diyBtnClicked {
    [UIView animateWithDuration:0.3 animations:^{
        self.diyView.alpha = 1;
        if (self.mute.selected) {
            [[BMHomePlayEffectHelper sharedInstance] setAllVolumeMute:NO];
            self.mute.selected = NO;
        }
    }];
}
- (void)muteBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    [[BMHomePlayEffectHelper sharedInstance] setAllVolumeMute:btn.selected];
}

- (void)moreBtnClicked {
}

#pragma mark ——— delegate


#pragma mark ——— setter and getter
- (BMHomeViewDiyView *)diyView {
    if (!_diyView) {
        BMHomeViewDiyView *view = [[BMHomeViewDiyView alloc] init];
        _diyView = view;
        [[kBMAppDelegate window] addSubview:_diyView];
        _diyView.alpha = 0;
        [_diyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    return _diyView;
}

@end
