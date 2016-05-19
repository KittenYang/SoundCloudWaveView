//
//  UIColor+Hex.h
//  SoundCloudWaveViewDemo
//
//  Created by Kitten x iDaily on 16/5/7.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface UIColor (Hex)


@end
