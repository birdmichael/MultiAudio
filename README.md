---
typora-root-url: ../MultiAudio
typora-copy-images-to: ../MultiAudio
---

![logo](/logo.jpg)

## 安装

为了包的体积，手机运行会报错找不到`pod`,在`MultiAudio`文件夹内运行`pod install`即可。

## 使用pods目录

pod 'Masonry'  -> 部分页面布局使用
pod 'MJExtension' -> 声音资源转模型使用
pod 'BMPrivatePods' -> 私有库，主要动些宏定义（项目快速移植版本，懒的特调）
pod 'Texture'-> 部分界面使用到了ASDK。（项目原本使用的ASDK，不影响阅读，换成VIew也可以）

## 截图演示(声音播放部分无法演示)



![222](/222.gif)

## 主代码说明

### BMHomeDiyItem

```
/** 名称 */
@property (nonatomic, copy) NSString *name;
/** 本地音乐地址 */
@property (nonatomic, copy) NSString *pathName;
/** 图片名称 */
@property (nonatomic, copy) NSString *imageName;
/** 背景起点颜色 */
@property (nonatomic, copy) NSString *bgFromColor;
/** 背景重点颜色 */
@property (nonatomic, copy) NSString *bgToColor;
/** 声音(播放器声音大小保存到模型) */
@property (nonatomic, assign) CGFloat volume;
```

重写`- (BOOL)isEqual:(BMHomeDiyItem *)object `通过文件地址判断对象匹配。

这里配置一个plist 最快。

### BMHomePlayEffectHelper

```
@property (nonatomic, strong ,readonly) NSArray *playEffectArray;

+ (instancetype)sharedInstance;

// 添加音效，每次添加音效自动播放。（播放所有音效和Diy cell选中状态双向绑定）
- (BOOL)addPlayEffect:(BMHomeDiyItem *)item;
- (BOOL)removePlayEffect:(BMHomeDiyItem *)item;
- (void)removeAllPlayEffects;
- (void)setAllVolumeMute:(BOOL)isMute;
- (void)setVolume:(CGFloat)volume WithEffect:(BMHomeDiyItem *)item;
```

helper为单利模式维护。

`playEffectArray`数组维护选中音效。

`addPlayEffect：`方法会判断数组个数，否则添加失败，项目需求。

`removePlayEffect`会判断是否含有这个音效，否则返回`NO`;

```
- (void)playSounds:(BMHomeDiyItem *)item {
    NSURL *fileURL = [[NSBundle bundleForClass:[self class]] URLForResource:item.pathName withExtension:@"mp3"];
    NSError *error;
    AVAudioPlayer *audioPlayer;
    @try {
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    }@catch(id anException){
    }
    [self.players setObject:audioPlayer forKey:item.pathName];
    if (audioPlayer) {
        audioPlayer.numberOfLoops = -1; // 无限循环播放
        audioPlayer.enableRate = NO; // 设置为 YES 可以控制播放速率
        [audioPlayer prepareToPlay];
        [audioPlayer play];
        NSTimeInterval delayTime =  0.01;
        audioPlayer.volume = 1.0;
        [audioPlayer playAtTime:delayTime];
    }else {
        NSLog(@"创建播放器出错 error: %@",[error localizedDescription]);
    }
}
```

多音频同事播放，其实就是创建多个`AVAudioPlayer`并且持有，就可以一直播放，这里简单使用的字典存放，`key`为播放路径名称（资源名称）。

更好的方式是用过`NSOperationQueue`来持有，这样可以有更多依赖关系在里面。

内部还有一个`playersLastVolume`字典存放静音前的音量。

### BMHomeViewDiyItemCollectionViewCell

cell结构说明

![1](/1.jpeg)

细节说明

1.设置音量手势

```
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
```

这里采用的是递减，导致`UIGestureRecognizerStateEnded`时不能单纯判断0，而是一个安全非极值判断，然后模拟再次点击关闭（点击在`iOS 10`添加了`UIImpactFeedbackGenerator`震动反馈）

`tapAction`点击方法说明：

1.通过`BMHomePlayEffectHelper`返回`BOOL`值来判断添加或者移除声音成功失败来控制选中状态。

2.震动反馈

3.通过按钮选中状态来添加水滴以及手势或移除手势。

### WaveSchedule(水滴及水波主动画view)

对外接口

```
// 配置水滴及水波颜色以及尺寸(渐变颜色尺寸为刚需值)
- (void)updateViewGradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withRange:(int)range;
// 修改水波的高度 (手势修改声音后，通过此方法修改水波高度)
- (void)drawWaterWavePath:(NSNumber *)percent;
// 开始动画(完整动画为：水滴，水波，停止)
- (void)showDripAnmin:(NSNumber *)percent;
```

#### 水滴

水滴动画通过`resetBeahviors`添加`UIDynamicAnimator`添加自由逻辑已经碰撞动画获取水滴降落完毕时机。

在`UICollisionBehavior`代理中获取水滴降落完毕代理后，隐藏水滴，并开始水滴溅起动画。

溅起动画通过

```
[self performSelector:@selector(addAnimationToDrip:) withObject:_dripLayers[i] afterDelay:i * 0.01];
```

分别延迟0.01来制造溅起自然感觉。

然后通过`CGFloat width = arc4random() % 9 + 2;`随机水滴大小，以及关键帧动画改变`position`。

设置动画代理，在`animationDidStop：finished：`动画结束后，在`_dripLayers`数组中移除所以溅起水滴，并开始水波动画。

#### 水波

水波动画属性值

```
//使用波形曲线y=Asin(ωx+φ)+k进行绘制
@property (assign ,nonatomic)CGFloat zoomY;// 波纹振幅A
@property (assign ,nonatomic)CGFloat translateX;// 波浪水平位移 Φ
@property (assign ,nonatomic)CGFloat currentWavePointY;// 波浪当前的高度 k
```

```
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
```

通过`CADisplayLink`同步屏幕刷新频率定时器调用`setCurrentWave:`方法来绘制水波动画。

```
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
```

绘制方法中通过自增`dripPercent`以及自减`zoomY`来绘制正弦波浪公式。



附：项目需求是在水波动画3秒后自动停止



## 联系

邮箱：birdmichael126@gmail.com

微信：birdmichael

## License

The Texture project is available for free use, as described by the [LICENSE](https://github.com/texturegroup/texture/blob/master/LICENSE) (Apache 2.0).
