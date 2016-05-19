//
//  PostContentCellSoundView.m
//  SoundCloudWaveViewDemo
//
//  Created by Kitten x iDaily on 16/5/7.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import "PostContentCellSoundView.h"

@interface PostContentCellSoundView() <WRWaveformViewDelegate>

@property (weak, nonatomic) IBOutlet WRSoundWaveView *soundWaveView;
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *restTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *overlayerView;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) Sound *currentMusic;

@end

@implementation PostContentCellSoundView

- (id)initWithCoder:(NSCoder *)aDecoder  {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [self setUp];
}

- (void)setUp {
    self.soundWaveView.waveColor = UIColorFromRGB(0x6A6B6C);
    self.soundWaveView.progressColor = UIColorFromRGB(0xFF1BA7);
    self.soundWaveView.lineCount = 100;
    self.playedTimeLabel.backgroundColor = self.soundWaveView.progressColor;
    self.restTimeLabel.backgroundColor = self.soundWaveView.waveColor;
    self.soundWaveView.delegate = self;
    NSTimer *updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:updateTimeTimer forMode:NSRunLoopCommonModes];
}

- (void)playSound:(NSString *)fileName {    
    [[SoundManager sharedManager] playMusic:fileName looping:NO];
    self.currentMusic = [[SoundManager sharedManager] currentMusic];
    
    __weak PostContentCellSoundView *weakSelf = self;
    [self.currentMusic setPlayingBlock:^(double progress){
        if (!weakSelf.soundWaveView.isPanning) {
            weakSelf.progress = progress;
        }
    }];
}

- (void)stopSound {
    [self.currentMusic stop];
}

- (void)resumeSound {
    if (![self.currentMusic isPlaying]) {
        [self.currentMusic play];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setUpGradient];
}

#pragma mark - getter
- (NSMutableArray *)volumeArray {
    return self.soundWaveView.volumeArray;
}

#pragma mark - setter
- (void)setSoundURL:(NSURL *)soundURL {
    _soundURL = soundURL;
    self.soundWaveView.soundURL = soundURL;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.soundWaveView.progress = progress;
}

#pragma mark - private
- (void)updateTime {
    self.playedTimeLabel.text = [self secondToMinute:self.currentMusic.currentTime];
    self.restTimeLabel.text = [self secondToMinute:(self.currentMusic.duration - self.currentMusic.currentTime)];
}

#pragma mark - helper
- (NSString *)secondToMinute:(double)second {
    int minutes = (int)floor(second/60);
    int seconds = (int)round(second- minutes * 60);
    NSString *playedTime = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    return playedTime;
}

- (void)setUpGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.overlayerView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.overlayerView.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - WRWaveformViewDelegate
- (void)waveformViewWillRender:(WRSoundWaveView *)waveformView {
    NSLog(@"开始渲染");
}

- (void)waveformViewDidRender:(WRSoundWaveView *)waveformView {
    NSLog(@"图片渲染完成");
    NSLog(@"%@",self.volumeArray);
}

- (void)waveformWillBeginGesture:(WRSoundWaveView *)waveformView progress:(CGFloat)progress{
    NSLog(@"触碰");
}

- (void)waveformDidEndGesture:(WRSoundWaveView *)waveformView progress:(CGFloat)progress {
    self.currentMusic.currentTime = self.currentMusic.duration * progress;
    [self updateTime];
    NSLog(@"事件完成");
}

@end
