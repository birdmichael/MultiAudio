//
//  BMHomePlayEffectHelper.m
//  Calm
//
//  Created by BirdMichael on 2018/10/17.
//  Copyright © 2018 BirdMichael. All rights reserved.
//

#import "BMHomePlayEffectHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface BMHomePlayEffectHelper ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *players;
@property (nonatomic, strong) NSMutableDictionary *playersLastVolume;
@property (nonatomic, strong) NSMutableArray *effectArray;

@end

@implementation BMHomePlayEffectHelper

+ (instancetype)sharedInstance {
    static BMHomePlayEffectHelper *_sharedMusicIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMusicIndicator = [[BMHomePlayEffectHelper alloc] init];
    });
    
    return _sharedMusicIndicator;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.effectArray = [@[] mutableCopy];
        self.players = [@{} mutableCopy];
        self.playersLastVolume = [@{} mutableCopy];
        self.queue = [[NSOperationQueue alloc] init];
        [self setupAudioSession];
    }
    return self;
}
- (void)setupAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    // 指定音频会话分类
    BOOL isSessionCategory = [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!isSessionCategory) {
        NSLog(@"AVAudioSession setCategory:error: %@",[error localizedDescription]);
    }
    // 设置为yes 激活会话
    BOOL isSessionActive = [session setActive:YES error:&error];
    if (!isSessionActive) {
        NSLog(@"AVAudioSession setActive:error: %@",[error localizedDescription]);
    }
}

- (BOOL)addPlayEffect:(BMHomeDiyItem *)item {
    if (self.effectArray.count >= 3) return NO;
    [self.effectArray addObject:item];
    [self playSounds:item];
    return YES;
}

- (BOOL)removePlayEffect:(BMHomeDiyItem *)item {
    if (![self.effectArray containsObject: item])return NO;
    [self.players removeObjectForKey:item.pathName];
    [self.effectArray removeObject:item];
    return YES;
}
- (void)removeAllPlayEffects {
    [self.players removeAllObjects];
    [self.effectArray removeAllObjects];
    [self.playersLastVolume removeAllObjects];
}

- (void)setAllVolumeMute:(BOOL)isMute {
    if (isMute) {
        // 静音
        for (BMHomeDiyItem *item in self.effectArray) {
            AVAudioPlayer *audioPlayer = [self.players objectForKey:item.pathName];
            [self.playersLastVolume setObject:@(audioPlayer.volume) forKey:item.pathName];
            audioPlayer.volume = 0.0;
        }
    }else {
        for (BMHomeDiyItem *item in self.effectArray) {
            AVAudioPlayer *audioPlayer = [self.players objectForKey:item.pathName];
            audioPlayer.volume = [[self.playersLastVolume objectForKey:item.pathName] floatValue];
        }
    }
}


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

- (void)setVolume:(CGFloat)volume WithEffect:(BMHomeDiyItem *)item {
    if (![self.effectArray containsObject: item])return;
    AVAudioPlayer *audioPlayer = [self.players objectForKey:item.pathName];
    if (audioPlayer) {
        audioPlayer.volume = volume;
    }
    
}

- (NSArray *)playEffectArray {
    return [self.effectArray copy];
}
@end
