//
//  BMHomeViewDiyView.m
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import "BMHomeViewDiyView.h"
#import "BMHomeDiyItem.h"
#import "BMHomeVIewDiyItemContetNode.h"
#import <Masonry.h>
#import <BMPrivatePodsHeader.h>


@interface BMHomeViewDiyView ()
@property (nonatomic, copy) NSArray<BMHomeDiyItem *> *modelArray;
/** close */
@property (nonatomic, strong) UIButton *closeBtn;
/** item容器 */
@property (nonatomic, strong) BMHomeVIewDiyItemContetNode *itmeContentNode;
@end

@implementation BMHomeViewDiyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBaseInfo];
    }
    return self;
}

- (void)setupBaseInfo {
    self.backgroundColor = BM_HEX_RGBA(0x000000, 0.9);
    [self addSubview:self.closeBtn];
    [self addSubnode:self.itmeContentNode];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kBMStatusBarHeight + BM_FitW(55));
        make.right.mas_equalTo(-BM_FitW(45));
    }];
    
}

- (void)dissMiss {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark ——— setter and getter
- (NSArray<BMHomeDiyItem *> *)modelArray {
    if (!_modelArray) {
        _modelArray  =[BMHomeDiyItem getLocalData];
    }
    return _modelArray;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        __weak __typeof(self)weakSelf = self;
        _closeBtn.bm_touchAreaInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_closeBtn bm_touchUpInside:^{
            [weakSelf dissMiss];
        }];
    }
    return _closeBtn;
}

- (BMHomeVIewDiyItemContetNode *)itmeContentNode {
    if (!_itmeContentNode) {
        _itmeContentNode = [[BMHomeVIewDiyItemContetNode alloc] initWithDataArray:self.modelArray];
        _itmeContentNode.view.backgroundColor = [UIColor clearColor];
        _itmeContentNode.frame = CGRectMake(0, kBMStatusBarHeight + BM_FitW(211),kBMSCREEN_WIDTH, kBMSCREEN_HEIGHT - kBMStatusBarHeight - BM_FitW(211));
    }
    return _itmeContentNode;
}

- (void)dealloc {
    NSLog(@"divVIew");
    
}

@end
