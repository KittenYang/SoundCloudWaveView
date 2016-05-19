//
//  WRSoundWaveView.h
//  SoundCloudWaveViewDemo
//
//  Created by Kitten Yang on 16/5/7.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WRWaveformViewDelegate;

@interface WRSoundWaveView : UIView

@property (nonatomic, weak) id<WRWaveformViewDelegate> delegate;

@property (nonatomic, strong) NSURL *soundURL;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIColor *waveColor;

@property (nonatomic, strong) UIColor *progressColor;

@property (nonatomic, assign) NSInteger lineCount;

@property (nonatomic, assign) BOOL isPanning;

@property (nonatomic, strong) NSMutableArray *volumeArray;

@end

@protocol WRWaveformViewDelegate <NSObject>
@optional
- (void)waveformViewWillRender:(WRSoundWaveView *)waveformView;
- (void)waveformViewDidRender:(WRSoundWaveView *)waveformView;
- (void)waveformWillBeginGesture:(WRSoundWaveView *)waveformView progress:(CGFloat)progress;
- (void)waveformDidEndGesture:(WRSoundWaveView *)waveformView progress:(CGFloat)progress;
@end