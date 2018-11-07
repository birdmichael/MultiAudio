//
//  BMHomeVIewDiyItemContetNode.m
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import "BMHomeVIewDiyItemContetNode.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "BMHomeViewDiyItemCollectionViewCell.h"
#import "BMHomePlayEffectHelper.h"
#import <BMPrivatePodsHeader.h>
#import <Masonry.h>
#define BM_CLAM_FONT(v) [UIFont systemFontOfSize:(v)]
#define BM_CLAM_BOLD_FONT(v) [UIFont boldSystemFontOfSize:(v)]

static const NSInteger kBMDiyItemContetLineSpacing = 35;
static const NSInteger kBMDiyItemContetItemSpacing = 25;
static NSString * const kCellIdentifier = @"collectionView";
static NSString * const kTipsLabelAlphaAnimation = @"kTipsLabelAlphaAnimation";

@interface BMHomeVIewDiyItemContetNode ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<BMHomeDiyItem *> *dataArray;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) UILabel *tipsLabel;
@end

@implementation BMHomeVIewDiyItemContetNode

- (instancetype)initWithDataArray:(NSArray<BMHomeDiyItem *> *)dataArray;
{
    self = [super init];
    if (self) {
        _dataArray = dataArray;
        self.view.userInteractionEnabled = YES;
        
    }
    return self;
}

- (void)didLoad {
    [super didLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self setupUI];
}
- (void)layoutDidFinish {
    [super layoutDidFinish];
    self.collectionView.frame = CGRectMake(0, 0, BM_WIDTH(self.view), BM_HEIGHT(self.view));
    self.tipsView.bm_Size = CGSizeMake(BM_FitW(450), BM_FitW(110));
    self.tipsView.bm_CenterX = self.collectionView.bm_CenterX;
    self.tipsView.bm_Y = self.collectionView.bm_BottomEdge;
}


#pragma mark ——— 私有方法
- (void)setupUI {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = kBMDiyItemContetLineSpacing;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.contentInset = UIEdgeInsetsMake(0, kBMDiyItemContetItemSpacing, 0, kBMDiyItemContetItemSpacing);
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.allowsMultipleSelection = YES;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView registerClass:[BMHomeViewDiyItemCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    [self.view addSubview:self.tipsView];
}

- (void)showtTipsView:(NSString *)text {
    self.tipsLabel.text = text;
    // animate
    // 入场动画
    [_tipsView.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn  animations:^{
        self.tipsView.bm_Y = self.collectionView.bm_BottomEdge - BM_FitW(74) - self.tipsView.bm_Height;
    } completion:^(BOOL finished) {
        if (finished) {
            // 退场
            [UIView animateWithDuration:0.3 delay:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.tipsView.bm_Y = self.collectionView.bm_BottomEdge;
            } completion:nil];
        }
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BMHomeViewDiyItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    BMHomeDiyItem *model = self.dataArray[indexPath.row];
    // 设置当前选中
    cell.model = model;
    __weak __typeof(self)weakSelf = self;
    [cell updateClickedItemAddSuccess:nil addFail:^(BMHomeDiyItem * _Nonnull model) {
        [weakSelf showtTipsView:@"You can only select up to 3 items at the same time"];
    } removeSuccess:nil];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.transform = CGAffineTransformIdentity;
    } completion:nil];
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat ItemWith = (kBMSCREEN_WIDTH - (kBMDiyItemContetItemSpacing * 4))/3;
    return CGSizeMake(ItemWith, ItemWith + BM_FitW(50));
}

#pragma mark ——— setter and getter

- (UIView *)tipsView {
    if (!_tipsView) {
        _tipsView = [UIView new];
        _tipsView.backgroundColor = BM_HEX_RGB(0x201F24);
        BMViewRadius(_tipsView, 15);
        
        _tipsLabel = [UILabel new];
        _tipsLabel.text = @"You can only select up to 3 items at the same time";
        _tipsLabel.numberOfLines = 2;
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = BM_CLAM_FONT(15);
        _tipsLabel.textColor = [UIColor whiteColor];
        [_tipsView addSubview:_tipsLabel];
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    return _tipsView;
}


- (void)dealloc {
    NSLog(@"connode");
}

@end
