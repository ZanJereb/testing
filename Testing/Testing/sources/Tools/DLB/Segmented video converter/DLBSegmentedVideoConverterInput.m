//
//  DLBSegmentedVideoConverterInput.m
//  Outcast
//
//  Created by Matic Oblak on 5/27/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import "DLBSegmentedVideoConverterInput.h"
#import "DLBSegmentedVideoConverterAsset.h"
@import AVFoundation;

@interface DLBSegmentedVideoConverterInput()

@property (nonatomic, strong) DLBSegmentedVideoConverterAsset *asset;
@property (nonatomic, strong) AVAssetReader *assetVideoReader;
@property (nonatomic, strong) AVAssetReader *assetAudioReader;
@property (nonatomic, strong) AVAssetReaderTrackOutput *videoTrackOutput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *audioTrackOutput;
@property (nonatomic, strong) NSError *error;

@end


@implementation DLBSegmentedVideoConverterInput

- (instancetype)initWithAsset:(DLBSegmentedVideoConverterAsset *)asset
{
    if((self = [super init]))
    {
        self.asset = asset;
    }
    return self;
}
- (BOOL)loadComponents
{
    self.videoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:self.asset.videoTracks.firstObject outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)}];
    NSError *error = nil;
    self.assetVideoReader = [AVAssetReader assetReaderWithAsset:self.asset.asset error:&error];
    if(error)
    {
        self.error = error;
        return NO;
    }
    if([self.assetVideoReader canAddOutput:self.videoTrackOutput])
    {
        [self.assetVideoReader addOutput:self.videoTrackOutput];
    }
    else
    {
        return NO;
    }
    
    if(self.asset.audioTracks.firstObject)
    {
        self.audioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:self.asset.audioTracks.firstObject outputSettings:[self createAudioInputSettings]];
        error = nil;
        self.assetAudioReader = [AVAssetReader assetReaderWithAsset:self.asset.asset error:&error];
        if(error)
        {
            self.error = error;
            return NO;
        }
        if([self.assetAudioReader canAddOutput:self.audioTrackOutput])
        {
            [self.assetAudioReader addOutput:self.audioTrackOutput];
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

- (NSDictionary *)createAudioInputSettings
{
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    return @{
             AVFormatIDKey : @(kAudioFormatLinearPCM),
             AVSampleRateKey : @(44100.0),
             AVNumberOfChannelsKey : @(2),
             AVChannelLayoutKey : [NSData dataWithBytes:&acl length:sizeof(acl)],
             AVLinearPCMBitDepthKey : @(16),
             AVLinearPCMIsNonInterleaved : @(NO),
             AVLinearPCMIsFloatKey : @(NO),
             AVLinearPCMIsBigEndianKey : @(NO)
             };
}

- (CMSampleBufferRef)copyAudioBuffer
{
    CMSampleBufferRef audioBuffer = [self.audioTrackOutput copyNextSampleBuffer];
    return audioBuffer;
}
- (CMSampleBufferRef)copyVideoBuffer
{
    CMSampleBufferRef videoBuffer = [self.videoTrackOutput copyNextSampleBuffer];
    return videoBuffer;
}

- (void)startReadingAudio
{
    [self.assetAudioReader startReading];
}
- (void)startReadingVideo
{
    [self.assetVideoReader startReading];
}

@end
