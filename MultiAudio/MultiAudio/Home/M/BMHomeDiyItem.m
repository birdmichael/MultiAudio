//
//  BMHomeDiyItem.m
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import "BMHomeDiyItem.h"
#import "MJExtension.h"

@implementation BMHomeDiyItem

+ (NSArray<BMHomeDiyItem *> *)getLocalData{
    NSArray *keys = @[@"name",@"pathName",@"imageName"];
    NSArray *values = @[@"Wind",@"Rain",@"Fire",@"River",@"Thunder",@"Ocean",@"Forest",@"Train",@"City"];
    
    NSMutableArray *array = [@[] mutableCopy];
    for (int i = 0; i<values.count; i++) {
        NSMutableDictionary *dict= [@{
                                      keys[0]:values[i],
                                      keys[2]:values[i],
                                      keys[1]:values[i],
                                      
                                      } mutableCopy];
        [dict setObject:@(0.5) forKey:@"volume"];
        [self getColorWithindex:i dict:dict];
        [array addObject:dict];
        
    }
    NSArray *modeArray = [BMHomeDiyItem mj_objectArrayWithKeyValuesArray:array];
    return modeArray;
}

- (BOOL)isEqual:(BMHomeDiyItem *)object {
    if (!self.name ||!object.name) return NO;
    if ([self.name isEqualToString:@""] || [object.name isEqualToString:@""])return NO;
    
    if ([self.name isEqualToString:object.name]) {
        return YES;
    }else {
        return NO;
    }
}

+ (void)getColorWithindex:(NSUInteger )index dict:(NSMutableDictionary *)dict{
    switch (index) {
        case 0:
            [dict setValue:@"EFCB23" forKey:@"bgFromColor"];
            [dict setValue:@"5EFFDB" forKey:@"bgToColor"];
            break;
        case 1:
            [dict setValue:@"3B3BF1" forKey:@"bgFromColor"];
            [dict setValue:@"D74AFF" forKey:@"bgToColor"];
            break;
        case 2:
            [dict setValue:@"F13B3B" forKey:@"bgFromColor"];
            [dict setValue:@"D74AFF" forKey:@"bgToColor"];
            break;
        case 3:
            [dict setValue:@"346DFF" forKey:@"bgFromColor"];
            [dict setValue:@"4AFF8E" forKey:@"bgToColor"];
            break;
        case 4:
            [dict setValue:@"F13B3B" forKey:@"bgFromColor"];
            [dict setValue:@"FFEC4A" forKey:@"bgToColor"];
            break;
        case 5:
            [dict setValue:@"34E5FF" forKey:@"bgFromColor"];
            [dict setValue:@"794AFF" forKey:@"bgToColor"];
            break;
        case 6:
            [dict setValue:@"39E180" forKey:@"bgFromColor"];
            [dict setValue:@"42E9C4" forKey:@"bgToColor"];
            break;
        case 7:
            [dict setValue:@"252735" forKey:@"bgFromColor"];
            [dict setValue:@"B4A8B7" forKey:@"bgToColor"];
            break;
        case 8:
            [dict setValue:@"F334FF" forKey:@"bgFromColor"];
            [dict setValue:@"FFE27D" forKey:@"bgToColor"];
            break;
        default:
            break;
    }
}



@end
