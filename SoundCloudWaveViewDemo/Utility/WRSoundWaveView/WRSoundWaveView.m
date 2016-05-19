//
//  WRSoundWaveView.m
//  SoundCloudWaveViewDemo
//
//  Created by Kitten Yang on 16/5/7.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import "WRSoundWaveView.h"
//#import <AVFoundation/AVFoundation.h>
#import "WRHelper.h"
#import "UIImage+Tint.h"

@interface WRSoundWaveView()

@property (nonatomic, strong) UIImageView *waveImageView;
@property (nonatomic, strong) UIImageView *progressImageView;
@property (nonatomic, strong) CAShapeLayer *progressMask;
@property (nonatomic, assign) CGFloat drawSpaces;

@end

@implementation WRSoundWaveView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_waveImageView == nil){
        _waveImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _progressImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _waveImageView.contentMode = UIViewContentModeLeft;
        _progressImageView.contentMode = UIViewContentModeLeft;
        _waveImageView.clipsToBounds = YES;
        _progressImageView.clipsToBounds = YES;
        _progressMask = [CAShapeLayer layer];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:_progressImageView.bounds];
        _progressMask.path = maskPath.CGPath;
        _progressImageView.layer.mask = _progressMask;
        [self addSubview:_waveImageView];
        [self addSubview:_progressImageView];
        self.progress = 0.0;
    }
}

#pragma mark - setter
- (void)setLineCount:(NSInteger)lineCount {
    _lineCount = lineCount;
    _drawSpaces = self.width / lineCount;
}
- (void)setSoundURL:(NSURL *)soundURL {
    _soundURL = soundURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self render];
    });
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progressMask.position = CGPointMake(-self.width*(1-progress), 0);
    [CATransaction commit];
}

#pragma mark - private
- (void)render {
    UIImage *renderedImage = [WRHelper renderWaveImageFromAudioURL:_soundURL toSize:self.size lineSpace:_drawSpaces lineColor:_waveColor backgroundColor:self.backgroundColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _waveImageView.image = renderedImage;
        _progressImageView.image = [renderedImage imageWithTintColor:_progressColor];
        
        _waveImageView.width = renderedImage.size.width;
        _waveImageView.left = 0;
        _progressImageView.left = _waveImageView.left;
        
        if ([self.delegate respondsToSelector:@selector(waveformViewDidRender:)]){
            [self.delegate waveformViewDidRender:self];
        }
    });
}

#pragma mark - getter
- (NSMutableArray *)volumeArray {
    if (_volumeArray == nil) {
        _volumeArray = [WRHelper getVolumeArrayFromAudioURL:_soundURL toSize:self.size lineSpace:_drawSpaces];
    }
    return _volumeArray;
}

#pragma mark - gesture handler
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isPanning = YES;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint)) {
        self.progress = touchPoint.x / self.width;
    }
    if ([self.delegate respondsToSelector:@selector(waveformWillBeginGesture:progress:)]) {
        [self.delegate waveformWillBeginGesture:self progress:_progress];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint)) {
        self.progress = touchPoint.x / self.width;
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(waveformDidEndGesture:progress:)]) {
        [self.delegate waveformDidEndGesture:self progress:_progress];
    }
    _isPanning = NO;
    [super touchesEnded:touches withEvent:event];
}

@end
