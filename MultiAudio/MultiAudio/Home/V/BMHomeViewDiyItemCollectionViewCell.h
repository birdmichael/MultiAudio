//
//  BMHomeViewDiyItemCollectionViewCell.h
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMHomeDiyItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BMHomeViewDiyItemAddSuccess)(BMHomeDiyItem *model);
typedef void (^BMHomeViewDiyItemAddFail)(BMHomeDiyItem *model);
typedef void (^BMHomeViewDiyItemRemoveSuccess)(BMHomeDiyItem *model);

@interface BMHomeViewDiyItemCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) BMHomeDiyItem *model;

- (void)updateClickedItemAddSuccess:(nullable BMHomeViewDiyItemAddSuccess)addSuccess addFail:(nullable BMHomeViewDiyItemAddFail)addFail removeSuccess:(nullable BMHomeViewDiyItemRemoveSuccess )removeSuccess;


@end

NS_ASSUME_NONNULL_END
