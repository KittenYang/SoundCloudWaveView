//
//  WRHelper.h
//  SoundCloudWaveViewDemo
//
//  Created by Kitten x iDaily on 16/5/8.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRHelper : NSObject

+ (NSMutableArray *)getVolumeArrayFromAudioURL:(NSURL *)soundURL toSize:(CGSize)size lineSpace:(CGFloat)lineSpace;

+ (UIImage *)renderWaveImageFromAudioURL:(NSURL *)soundURL toSize:(CGSize)size lineSpace:(CGFloat)lineSpace lineColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

@end
