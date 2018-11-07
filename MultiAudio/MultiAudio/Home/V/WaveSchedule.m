//
//  WaveSchedule.m
//  Calm
//
//  Created by BirdMichael on 2018/10/31.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import "WaveSchedule.h"
#import "BMDripView.h"

//typedef NS_ENUM(NSUInteger, WaveScheduleStatus) {
//  
//};

@interface WaveSchedule() <CAAnimationDelegate, UICollectionViewDelegate>
@property (strong ,nonatomic)CADisplayLink *displayLink;
@property (strong ,nonatomic)CAShapeLayer *waveLayer;
@property (assign ,nonatomic)CGFloat percent;
//使用波形曲线y=Asin(ωx+φ)+k进行绘制
@property (assign ,nonatomic)CGFloat zoomY;// 波纹振幅A
@property (assign ,nonatomic)CGFloat translateX;// 波浪水平位移 Φ
@property (assign ,nonatomic)CGFloat currentWavePointY;// 波浪当前的高度 k
@property (assign ,nonatomic)BOOL stop;
@property (strong, nonatomic) NSMutableArray *dripLayers;

@property (nonatomic, strong) BMDripView *dripView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIView *barrierLine;
@property (strong, nonatomic) UIColor *dripVColor;
@property (strong, nonatomic) UIColor *waveColor;
@property (assign, nonatomic) BOOL showDrip;
@property (assign ,nonatomic) CGFloat dripPercent;
@end
@implementation WaveSchedule
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.zoomY = 2.0f;
        [self resetLayer];
    }
    return self;
}

- (void)drawWaterWavePath:(NSNumber *)percent
{
    self.showDrip = NO;
    self.percent = percent.doubleValue;
    [self starWave];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopWave];
    });
}
- (void)starWave{
    
    [self resetLayer];
    [self resetProperty];
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    // 启动同步渲染绘制波纹
    self.stop = NO;
    self.zoomY = 1.0f;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setCurrentWave:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

//绘制波纹
- (void)setCurrentWave:(CADisplayLink *)displayLink
{
    // 配置动画相关
    if (self.showDrip) {
        if (self.dripPercent <= self.percent) {
            self.dripPercent += 0.005;
            [self resetProperty];
        }else {
            self.showDrip = NO;
            self.dripPercent = 0;
            self.stop = YES;
        }
    }

    
    // 水波
    self.translateX += 0.1;
    if (self.stop &&self.zoomY>0) {
        self.zoomY -= 0.15;
        if (self.zoomY<0) {
            // 清零 停止
            self.zoomY =0;
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
    }
    [self setCurrentWaveLayerPath];
}
- (void)setCurrentWaveLayerPath
{
    // 通过正弦曲线来绘制波浪形状
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.currentWavePointY)];
    CGFloat y= 0.0f;
    CGFloat width = CGRectGetWidth(self.frame);
    for (float x = 0.0f; x <= width; x++)
    {
        // 正弦波浪公式
        y = self.zoomY * sin(x / 180 * M_PI - 4 * self.translateX / M_PI)*5 + self.currentWavePointY;
        [path addLineToPoint:CGPointMake(x, y)];
    }
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(0, self.currentWavePointY)];
    [path closePath];
    self.waveLayer.path = path.CGPath;
}

- (void)stopWave
{
    self.stop = YES;
}

- (void)resetProperty
{
    // 重置属性
    if (self.showDrip) {
        self.currentWavePointY = CGRectGetHeight(self.frame) * (1-self.dripPercent);
    }else {
        self.currentWavePointY = CGRectGetHeight(self.frame) * (1-self.percent);
    }
    
}
- (void)resetLayer
{
    // 动画开始之前重置layer
    if (!self.waveLayer){
        self.waveLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.waveLayer];
        self.waveLayer.fillColor = self.waveColor.CGColor;
    }
}
- (void)updateViewGradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withRange:(int)range {
    UIColor *endColor = [self gradientFromColor:c1 toColor:c2 withRange:range];
    
    self.waveLayer.fillColor = endColor.CGColor;
    self.dripVColor = [self gradientFromColor:c2 toColor:c1 withRange:48];
    self.waveColor = endColor;
}

- (UIColor *)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withRange:(int)range {
    CGSize size = CGSizeMake(range, range);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    NSArray* colors = [NSArray arrayWithObjects:(id)c1.CGColor, (id)c2.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(size.width, 0), CGPointMake(0, size.width), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    UIColor *endColor = [UIColor colorWithPatternImage:image];
    return endColor;
}

#pragma mark ——— 水滴

static const CGFloat kDripCount = 10;

- (void)showDripAnmin:(NSNumber *)percent; {
    [self.waveLayer removeFromSuperlayer];
    self.waveLayer =nil;
    self.percent = percent.doubleValue;
    
    self.dripView = [[BMDripView alloc] initWithColor:self.dripVColor];
    [self addSubview:self.dripView];
    CGFloat dripViewWidth = 48.0f;
    CGFloat dripViewHeight = 32.0f;
    [_dripView setFrame:CGRectMake((self.bounds.size.width - dripViewWidth) * 0.5f,
                                   -dripViewHeight,
                                   dripViewWidth,
                                   dripViewHeight)];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.barrierLine = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_barrierLine];
    CGFloat waveViewHeight = self.bm_Height *0.3;
    _barrierLine.frame = CGRectMake(0,
                                    self.bounds.size.height - waveViewHeight * 0.5f + 40.0f,
                                    self.bounds.size.width,
                                    1);
    [self resetBeahviors];
}
- (void)resetBeahviors
{
    [_animator removeAllBehaviors];
    
    UIGravityBehavior *gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[_dripView]];
    [_animator addBehavior:gravityBeahvior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_dripView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = NO;
    
    
    CGPoint rightEdge = CGPointMake(_barrierLine.frame.origin.x + _barrierLine.frame.size.width,
                                    _barrierLine.frame.origin.y);
    
    [collisionBehavior addBoundaryWithIdentifier:@"barrier"
                                       fromPoint:_barrierLine.frame.origin
                                         toPoint:rightEdge];
    collisionBehavior.collisionDelegate = (id)self;
    [_animator addBehavior:collisionBehavior];
    
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_dripView, _barrierLine]];
    itemBehaviour.elasticity = 0.0;
    [_animator addBehavior:itemBehaviour];
}
- (void)collisionBehavior:(UICollisionBehavior*)behavior
      endedContactForItem:(id <UIDynamicItem>)item
   withBoundaryIdentifier:(id <NSCopying>)identifier
{
    [_animator removeAllBehaviors];
    [_dripView setHidden:YES];
    [self splashWater];
}

- (void)splashWater
{
    if (!_dripLayers) {
        _dripLayers = [[NSMutableArray alloc] initWithCapacity:kDripCount];
        
        for (int i = 0; i < kDripCount; i++) {
            
            CALayer *dripLayer = [CALayer layer];
            [_dripLayers addObject:dripLayer];
            
        }
    }
    for (int i = 0; i < kDripCount; i++) {
        [self performSelector:@selector(addAnimationToDrip:) withObject:_dripLayers[i] afterDelay:i * 0.01];
    }
    
}
- (void)stopSplashWater
{
    [_dripLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeAllAnimations];
        [obj removeFromSuperlayer];
    }];
}

- (void)addAnimationToDrip:(CALayer *)dripLayer
{
    CGFloat width = arc4random() % 9 + 2;
    dripLayer.frame = CGRectMake((self.bounds.size.width - width)* 0.5f, self.bounds.size.height * 0.5f + 40, width, width);
    dripLayer.cornerRadius = dripLayer.frame.size.width * 0.5f;
    dripLayer.backgroundColor = self.dripVColor.CGColor;
    
    [self.layer addSublayer:dripLayer];
    
    CGFloat x3 = arc4random() % ((int)self.bounds.size.width) + 1;
    CGFloat y3 = self.bounds.size.height * 0.5f + 40;
    
    CGFloat height = arc4random() % ((int)(self.bounds.size.height * 0.5f));
    
    [self throwDrip:dripLayer
               from:dripLayer.position
                 to:CGPointMake(x3, y3)
             height:height
           duration:0.8];
}
- (void)throwDrip:(CALayer *)drip
             from:(CGPoint)start
               to:(CGPoint)end
           height:(CGFloat)height
         duration:(CGFloat)duration
{
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddQuadCurveToPoint(path, NULL, (end.x + start.x) * 0.5f, -height, end.x, end.y);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    [animation setPath:path];
    animation.duration = duration;
    CFRelease(path);
    path = nil;
    
    [drip addAnimation:animation forKey:@"position"];
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self stopSplashWater];
        self.showDrip = YES;
        self.dripPercent = 0;
//        [self.waveLayer removeFromSuperlayer];
        [self starWave];
    }
}

@end
