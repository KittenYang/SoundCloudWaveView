//
//  WRHelper.m
//  SoundCloudWaveViewDemo
//
//  Created by Kitten x iDaily on 16/5/8.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

#import "WRHelper.h"
#import <AVFoundation/AVFoundation.h>

@implementation WRHelper

+ (NSMutableArray *)getVolumeArrayFromAudioURL:(NSURL *)soundURL toSize:(CGSize)size lineSpace:(CGFloat)lineSpace{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:soundURL options:nil];
    NSError* error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack* songTrack = [asset.tracks objectAtIndex:0];
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    UInt32 sampleRate, channelCount = 0;
    NSArray* formatDesc = songTrack.formatDescriptions;
    for (int i = 0; i < [formatDesc count]; ++i){
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if (fmtDesc){
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    SInt16 maxValue = 0;
    NSMutableData *fullSongData = [[NSMutableData alloc] init];
    
    [reader startReading];
    
    UInt64 totalBytes = 0;
    SInt64 totalLeft = 0;
    SInt64 totalRight = 0;
    NSInteger sampleTally = 0;
    
    NSInteger samplesPerPixel = 100; // pretty enougth for most of ui and fast
    int buffersCount = 0;
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            @autoreleasepool {
                NSMutableData *data = [NSMutableData dataWithLength:length];
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
                SInt16 * samples = (SInt16*) data.mutableBytes;
                int sampleCount = (int)length / bytesPerSample;
                for (int i = 0; i < sampleCount; i++) {
                    SInt16 left = *samples++;
                    totalLeft += left;
                    SInt16 right = 0;
                    
                    if (channelCount == 2){
                        right = *samples++;
                        totalRight += right;
                    }
                    sampleTally++;
                    if (sampleTally > samplesPerPixel){
                        left = (totalLeft / sampleTally);
                        if (channelCount == 2){
                            right = (totalRight / sampleTally);
                        }
                        SInt16 val = right ? ((right + left) / 2) : left;
                        [fullSongData appendBytes:&val length:sizeof(val)];
                        totalLeft = 0;
                        totalRight = 0;
                        sampleTally = 0;
                    }
                }
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
        }
        buffersCount++;
    }
    
    NSMutableData *adjustedSongData = [[NSMutableData alloc] init];
    
    int sampleCount = fullSongData.length / 2.0; // sizeof(SInt16)
    int adjustFactor = ceilf((float)sampleCount / (size.width / lineSpace));
    SInt16 *samples = (SInt16*) fullSongData.mutableBytes;
    
    int i = 0;
    while (i < sampleCount){
        SInt16 val = 0;
        for (int j = 0; j < adjustFactor; j++) {
            val += samples[i + j];
        }
        val /= adjustFactor;
        if (ABS(val) > maxValue) {
            maxValue = ABS(val);
        }
        [adjustedSongData appendBytes:&val length:sizeof(val)];
        i += adjustFactor;
    }
    
    NSMutableArray *volumeArray = [NSMutableArray array];
    sampleCount = adjustedSongData.length / 2.0;
    if (reader.status == AVAssetReaderStatusCompleted) {
        SInt16 *_samples = (SInt16 *)adjustedSongData.bytes;
        CGSize imageSize = CGSizeMake(sampleCount * lineSpace, size.height - 20);
        float sampleAdjustmentFactor = imageSize.height / (float)maxValue;
        for (NSInteger i = 0; i < sampleCount; i++) {
            float val = *_samples++;
            val = val * sampleAdjustmentFactor;
            if ((int)val == 0)
                val = -10.0; // draw dots instead emptyness
            if ((int)i == sampleCount-1)
                val = -10.0;
            if (ABS(val) >= imageSize.height-2)
                val = imageSize.height - 2;
            [volumeArray addObject:@(ABS(val))];
            NSLog(@"*i=%ld,val:%f",(long)i,val);
        }
    }
    return volumeArray;
}

+ (UIImage *)renderWaveImageFromAudioURL:(NSURL *)soundURL toSize:(CGSize)size lineSpace:(CGFloat)lineSpace lineColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:soundURL options:nil];
    NSError* error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack* songTrack = [asset.tracks objectAtIndex:0];
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    UInt32 sampleRate, channelCount = 0;
    NSArray* formatDesc = songTrack.formatDescriptions;
    for (int i = 0; i < [formatDesc count]; ++i){
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if (fmtDesc){
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    SInt16 maxValue = 0;
    NSMutableData *fullSongData = [[NSMutableData alloc] init];
    
    [reader startReading];
    
    UInt64 totalBytes = 0;
    SInt64 totalLeft = 0;
    SInt64 totalRight = 0;
    NSInteger sampleTally = 0;
    
    NSInteger samplesPerPixel = 100; // pretty enougth for most of ui and fast
    int buffersCount = 0;
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            @autoreleasepool {
                NSMutableData *data = [NSMutableData dataWithLength:length];
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
                SInt16 * samples = (SInt16*) data.mutableBytes;
                int sampleCount = (int)length / bytesPerSample;
                for (int i = 0; i < sampleCount; i++) {
                    SInt16 left = *samples++;
                    totalLeft += left;
                    SInt16 right = 0;
                    
                    if (channelCount == 2){
                        right = *samples++;
                        totalRight += right;
                    }
                    sampleTally++;
                    if (sampleTally > samplesPerPixel){
                        left = (totalLeft / sampleTally);
                        if (channelCount == 2){
                            right = (totalRight / sampleTally);
                        }
                        SInt16 val = right ? ((right + left) / 2) : left;
                        [fullSongData appendBytes:&val length:sizeof(val)];
                        totalLeft = 0;
                        totalRight = 0;
                        sampleTally = 0;
                    }
                }
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
        }
        buffersCount++;
    }
    
    NSMutableData *adjustedSongData = [[NSMutableData alloc] init];
    
    int sampleCount = fullSongData.length / 2.0; // sizeof(SInt16)
    int adjustFactor = ceilf((float)sampleCount / (size.width / lineSpace));
    SInt16 *samples = (SInt16*) fullSongData.mutableBytes;
    
    int i = 0;
    while (i < sampleCount){
        SInt16 val = 0;
        for (int j = 0; j < adjustFactor; j++) {
            val += samples[i + j];
        }
        val /= adjustFactor;
        if (ABS(val) > maxValue) {
            maxValue = ABS(val);
        }
        [adjustedSongData appendBytes:&val length:sizeof(val)];
        i += adjustFactor;
    }
    
    sampleCount = adjustedSongData.length / 2.0;
    if (reader.status == AVAssetReaderStatusCompleted) {
        UIImage *image = [self drawImageFromSamples:(SInt16 *)adjustedSongData.bytes
                                           maxValue:maxValue
                                        sampleCount:sampleCount
                                          lineSpace:lineSpace
                                             toSize:size
                                    backgroundColor:backgroundColor
                                              color:color];
        return image;
    }
    return nil;
}

+ (UIImage *)drawImageFromSamples:(SInt16*)samples
                        maxValue:(SInt16)maxValue
                      sampleCount:(NSInteger)sampleCount
                        lineSpace:(CGFloat)lineSpace
                           toSize:(CGSize)size
                  backgroundColor:(UIColor*)backgroundColor
                            color:(UIColor*)color{
    
    CGSize imageSize = CGSizeMake(sampleCount * lineSpace, size.height - 20);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextSetAlpha(context, 1.0);
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef waveColor = color.CGColor;
    CGContextFillRect(context, rect);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    float channelCenterY = imageSize.height / 2;
    float sampleAdjustmentFactor = imageSize.height / (float)maxValue;
    
    for (NSInteger i = 0; i < sampleCount; i++) {
        float val = *samples++;
        val = val * sampleAdjustmentFactor;
        if ((int)val == 0)
            val = -10.0; // draw dots instead emptyness
        if ((int)i == sampleCount-1)
            val = -10.0;
        if (ABS(val) >= imageSize.height-2)
            val = imageSize.height - 2;
        NSLog(@"i=%ld,val:%f",(long)i,val);
        CGContextMoveToPoint(context, i * lineSpace, channelCenterY - val / 2.0);
        CGContextAddLineToPoint(context, i * lineSpace, channelCenterY + val / 2.0);
        CGContextSetStrokeColorWithColor(context, waveColor);
        CGContextStrokePath(context);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
