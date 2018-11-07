//
//  BMHomeDiyItem.h
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMHomeDiyItem : NSObject
/** 名称 */
@property (nonatomic, copy) NSString *name;
/** 本地音乐地址 */
@property (nonatomic, copy) NSString *pathName;
/** 图片名称 */
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *bgFromColor;
@property (nonatomic, copy) NSString *bgToColor;
@property (nonatomic, assign) CGFloat volume;

+ (NSArray<BMHomeDiyItem *> *)getLocalData;

@end

NS_ASSUME_NONNULL_END
