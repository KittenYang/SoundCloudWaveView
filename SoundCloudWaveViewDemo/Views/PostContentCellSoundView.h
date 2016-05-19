//
//  PostContentCellSoundView.h
//  SoundCloudWaveViewDemo
//
//  Created by Kitten x iDaily on 16/5/7.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WRSoundWaveView.h"
#import "XXNibBridge.h"
#import "SoundManager.h"

@interface PostContentCellSoundView : UIView<XXNibBridge>

@property (nonatomic, strong) NSURL *soundURL;

@property (nonatomic, readonly) NSMutableArray *volumeArray;

- (void)playSound:(NSString *)fileName;

- (void)stopSound;

- (void)resumeSound;

@end
