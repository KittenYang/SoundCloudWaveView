//
//  ViewController.m
//  SoundCloudWaveViewDemo
//
//  Created by Kitten x iDaily on 16/5/20.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import "ViewController.h"
#import "PostContentCellSoundView.h"
#import "WRHelper.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet PostContentCellSoundView *postContentCellSoundView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)playMusic:(id)sender {
    NSString* filename = [NSString stringWithFormat:@"TchaikovskyExample2.mp3"];
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
    _postContentCellSoundView.soundURL = url;
    [_postContentCellSoundView playSound:filename];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
