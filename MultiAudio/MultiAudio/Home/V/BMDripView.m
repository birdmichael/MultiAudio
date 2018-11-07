//
//  BMDripView.m
//  Calm
//
//  Created by BirdMichael on 2018/11/1.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import "BMDripView.h"

@interface BMDripView ()
@property (nonatomic, strong) UIColor *color;
@end

@implementation BMDripView

- (instancetype)initWithColor:(UIColor *)color;
{
    self = [super init];
    if (self) {
        _color = color;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, self.bounds.size.width * 0.5f, 0);
    
    [[UIColor clearColor] set];
    CGContextSetLineWidth(context, 1.0);
    CGContextAddCurveToPoint(context,
                             0,
                             self.bounds.size.height,
                             self.bounds.size.width,
                             self.bounds.size.height,
                             self.bounds.size.width * 0.5f,
                             0);
    CGContextSetFillColorWithColor(context,self.color.CGColor);
    CGContextFillPath(context);
    
    CGContextStrokePath(context);
    
}

@end
