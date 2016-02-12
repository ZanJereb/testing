//
//  DLBSegmentedVideoConverter.m
//  Outcast
//
//  Created by Matic Oblak on 5/27/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import "DLBSegmentedVideoConverter.h"
#import "DLBSegmentedVideoConverterAsset.h"
#import "DLBSegmentedVideoConverterInput.h"
@import AVFoundation;

#define M_WAIT_INTERVAL(X) (.01*X)

@interface DLBSegmentedVideoConverter()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSArray *inputAssets;
@property (nonatomic) NSTimeInterval inputDuration;
@property (nonatomic) CMTime inputTime;

@property (nonatomic, strong) NSArray *mediaInputs;
@property (nonatomic) NSInteger currentAudioComponentIndex;
@property (nonatomic) NSInteger currentVideoComponentIndex;

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoAssetWriter;
@property (nonatomic, strong) AVAssetWriterInput *audioAssetWriter;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *inputAdaptor;

@property (nonatomic, readonly) CGFloat outputWidth;
@property (nonatomic, readonly) CGFloat outputHeight;

@property (nonatomic) NSInteger currentSampleSkipCount;
@property (nonatomic) CMTime currentVideoStartTime;
@property (nonatomic) CMTime currentAudioStartTime;

@end


@implementation DLBSegmentedVideoConverter

- (void)setOutputURL:(NSURL *)outputURL
{
    if([outputURL isKindOfClass:[NSString class]])
    {
        outputURL = [NSURL URLWithString:(NSString *)outputURL];
    }
    _outputURL = outputURL;
}

- (void)clearOutputPath
{
    NSError *error = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.outputURL path]])
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.outputURL error:&error];
        [self reportError:error withMessage:@"Clearing output path error"];
    }
}
- (void)loadInputData:(void (^)(NSArray *assets))callback
{
    {
        CMTime overallTime = kCMTimeZero;
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        for(NSURL *url in self.inputURLs)
        {
            DLBSegmentedVideoConverterAsset *asset = [[DLBSegmentedVideoConverterAsset alloc] initWithURL:url];
            overallTime = CMTimeAdd(overallTime, asset.duration);
            [assets addObject:asset];
        }
        self.inputAssets = [assets copy];
    }
    
    for(DLBSegmentedVideoConverterAsset *asset in self.inputAssets)
    {
        [asset loadBasicData:^(BOOL succeeded) {
            BOOL allLoaded = YES;
            for(DLBSegmentedVideoConverterAsset *asset in self.inputAssets)
            {
                if(asset.loaded == NO)
                {
                    allLoaded = NO;
                    break;
                }
            }
            if(allLoaded)
            {
                if(callback)
                {
                    callback(self.inputAssets);
                }
            }
        }];
    }
}

- (dispatch_queue_t)queue
{
    if(_queue == nil)
    {
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _queue;
}

- (CGFloat)outputWidth
{
    DLBSegmentedVideoConverterAsset *asset = self.inputAssets.firstObject;
    CGSize targetSize = asset.videoSize;
    if(self.outputVideoSize.width > .0f && self.outputVideoSize.height > .0f)
    {
        targetSize = self.outputVideoSize;
    }
    targetSize = CGSizeApplyAffineTransform(targetSize, asset.transform);
    return (CGFloat)fabs(targetSize.width);
}
- (CGFloat)outputHeight
{
    DLBSegmentedVideoConverterAsset *asset = self.inputAssets.firstObject;
    CGSize targetSize = asset.videoSize;
    if(self.outputVideoSize.width > .0f && self.outputVideoSize.height > .0f)
    {
        targetSize = self.outputVideoSize;
    }
    targetSize = CGSizeApplyAffineTransform(targetSize, asset.transform);
    return (CGFloat)fabs(targetSize.height);
}

- (CGFloat)bitRateScale
{
    if(_bitRateScale > .0f)
    {
        return _bitRateScale;
    }
    return 1.0f;
}

- (NSInteger)keyFrameSkipCount
{
    if(_keyFrameSkipCount > 0)
    {
        return _keyFrameSkipCount;
    }
    return 15*30*10000;
}

- (CGFloat)JPEGCodecQuality
{
    if(_JPEGCodecQuality > 0)
    {
        return _JPEGCodecQuality;
    }
    else
    {
        return .5f;
    }
}

- (NSDictionary *)downsampledVideoOutputSettings
{
    NSMutableDictionary *videoSettings = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *codecSettings = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *apertureSettings = [[NSMutableDictionary alloc] init];
    
    [apertureSettings setObject:@(self.outputWidth) forKey:AVVideoCleanApertureWidthKey];
    [apertureSettings setObject:@(self.outputHeight) forKey:AVVideoCleanApertureHeightKey];
    [apertureSettings setObject:@(0) forKey:AVVideoCleanApertureHorizontalOffsetKey];
    [apertureSettings setObject:@(0) forKey:AVVideoCleanApertureVerticalOffsetKey];
    
    [codecSettings setObject:apertureSettings forKey:AVVideoCleanApertureKey];
    if(self.useJPEGCodec)
    {
        [codecSettings setObject:@(self.JPEGCodecQuality) forKey:AVVideoQualityKey];
    }
    else
    {
        [codecSettings setObject:@(self.keyFrameSkipCount) forKey:AVVideoMaxKeyFrameIntervalKey];
        [codecSettings setObject:@(((int)self.bitRateScale*960000)) forKey:AVVideoAverageBitRateKey];
        [codecSettings setObject:AVVideoProfileLevelH264High40 forKey:AVVideoProfileLevelKey];
    }
    
    [videoSettings setObject:self.useJPEGCodec?AVVideoCodecJPEG:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [videoSettings setObject:codecSettings forKey:AVVideoCompressionPropertiesKey];
    [videoSettings setObject:@(self.outputWidth) forKey:AVVideoWidthKey];
    [videoSettings setObject:@(self.outputHeight) forKey:AVVideoHeightKey];
    [videoSettings setObject:AVVideoScalingModeResizeAspectFill forKey:AVVideoScalingModeKey];
    
    return videoSettings;
}
- (NSDictionary *)createVideoOutputSettings
{
    return [self downsampledVideoOutputSettings];
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
- (NSDictionary *)createAudioOutputSettings
{
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    return @{
             AVFormatIDKey : @(kAudioFormatMPEG4AAC),
             AVNumberOfChannelsKey : @(1),
             AVSampleRateKey : @(44100.0),
             AVEncoderBitRateKey : @(64000),
             AVChannelLayoutKey : [NSData dataWithBytes:&acl length:sizeof(acl)]
             };
}

- (void)prepareInputComponents
{
    NSMutableArray *inputs = [[NSMutableArray alloc] init];
    for(DLBSegmentedVideoConverterAsset *asset in self.inputAssets)
    {
        DLBSegmentedVideoConverterInput *input = [[DLBSegmentedVideoConverterInput alloc] initWithAsset:asset];
        BOOL success = [input loadComponents];
        if(!success)
        {
            if(input.error)
            {
                [self reportError:input.error withMessage:@"Failed loading input"];
            }
            else
            {
                [self reportError:[NSError errorWithDomain:@"internal" code:500 userInfo:nil] withMessage:@"Failed loading input"];
            }
        }
        else
        {
            [inputs addObject:input];
        }
    }
    self.mediaInputs = [inputs copy];
}

- (void)prepareOutputComponents
{
    NSError *error = nil;
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.outputURL fileType:AVFileTypeMPEG4 error:&error];
    [self reportError:error withMessage:@"Asset writer error"];
    [self prepareOutputWriters];
}

- (void)prepareOutputWriters
{
    self.audioAssetWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:[self createAudioOutputSettings]];
    if([self.assetWriter canAddInput:self.audioAssetWriter] == NO)
    {
        [self reportError:[NSError errorWithDomain:@"internal" code:404 userInfo:nil] withMessage:@"Can not add input to the asset writer"];
    }
    self.audioAssetWriter.expectsMediaDataInRealTime = NO;
    [self.assetWriter addInput:self.audioAssetWriter];
    
    self.videoAssetWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[self createVideoOutputSettings]];
    DLBSegmentedVideoConverterAsset *asset = self.inputAssets.firstObject;
    CGAffineTransform transform = CGAffineTransformIdentity;
    if(asset)
    {
        transform = asset.transform;
    }
    self.videoAssetWriter.transform = transform;
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                           @(self.outputWidth), kCVPixelBufferWidthKey,
                                                           @(self.outputHeight), kCVPixelBufferHeightKey,
                                                           nil];
    self.inputAdaptor = [AVAssetWriterInputPixelBufferAdaptor
                         assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoAssetWriter
                         sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    if([self.assetWriter canAddInput:self.videoAssetWriter] == NO)
    {
        [self reportError:[NSError errorWithDomain:@"internal" code:404 userInfo:nil] withMessage:@"Can not add input to the asset writer"];
    }
    self.videoAssetWriter.expectsMediaDataInRealTime = NO;
    [self.assetWriter addInput:self.videoAssetWriter];
}

- (DLBSegmentedVideoConverterInput *)currentAudioInput
{
    if(self.currentAudioComponentIndex >= 0 && self.currentAudioComponentIndex < (NSInteger)self.mediaInputs.count)
    {
        return self.mediaInputs[self.currentAudioComponentIndex];
    }
    else
    {
        return nil;
    }
}
- (DLBSegmentedVideoConverterInput *)currentVideoInput
{
    if(self.currentVideoComponentIndex >= 0 && self.currentVideoComponentIndex < (NSInteger)self.mediaInputs.count)
    {
        return self.mediaInputs[self.currentVideoComponentIndex];
    }
    else
    {
        return nil;
    }
}

- (void)insertInputBuffersCallback:(void (^)(void))callback
{
    BOOL audioDone = NO;
    BOOL videoDone = NO;
    NSTimeInterval currentAudioProgress = .0;
    NSTimeInterval currentVideoProgress = .0;
    
    BOOL breakAudioDueToMaximumDuration = NO;
    BOOL breakVideoDueToMaximumDuration = NO;
    
    for(;;)
    {
        BOOL audioReady = self.audioAssetWriter.readyForMoreMediaData;
        BOOL videoReady = self.videoAssetWriter.readyForMoreMediaData;
        
        BOOL didInsert = NO;
        if(audioReady && audioDone == NO)
        {
            CMSampleBufferRef audioBuffer = [[self currentAudioInput] copyAudioBuffer];
            if(audioBuffer && breakAudioDueToMaximumDuration == NO)
            {
                CMSampleTimingInfo timing;
                CMItemCount returnCount = 0;
                CMSampleBufferGetOutputSampleTimingInfoArray(audioBuffer, 1, &timing, &returnCount);
                CMTime time = timing.presentationTimeStamp;
                time = CMTimeAdd(self.currentAudioStartTime, time);
                
                NSTimeInterval timeInterval = CMTimeGetSeconds(time);
                
                if(self.maximumVideoDuration > .0 && timeInterval > self.maximumVideoDuration)
                {
                    breakAudioDueToMaximumDuration = YES;
                }
                
                if(timeInterval > currentAudioProgress)
                {
                    currentAudioProgress = timeInterval;
                    [self reportProgress:(currentAudioProgress+currentVideoProgress)*.5f];
                }
                
                BOOL didAppend = [self.audioAssetWriter appendSampleBuffer:audioBuffer];
                if(!didAppend)
                {
                    [self reportError:[NSError errorWithDomain:@"internal" code:500 userInfo:nil] withMessage:@"Failed appending the audio buffer"];
                    CFRelease(audioBuffer);
                    return;
                }
                CFRelease(audioBuffer);
            }
            else
            {
                self.currentAudioStartTime = CMTimeAdd(self.currentAudioStartTime, [self currentAudioInput].asset.duration);
                self.currentAudioComponentIndex++;
                if([self currentAudioInput] == nil)
                {
                    audioDone = YES;
                    [self.audioAssetWriter markAsFinished];
                }
                else
                {
                    [[self currentAudioInput] startReadingAudio];
                }
            }
            didInsert = YES;
        }
        if(videoReady && videoDone == NO)
        {
            CMSampleBufferRef videoBuffer = [[self currentVideoInput] copyVideoBuffer];
            if(videoBuffer && breakVideoDueToMaximumDuration == NO)
            {
                CMSampleTimingInfo timing;
                CMItemCount returnCount = 0;
                CMSampleBufferGetOutputSampleTimingInfoArray(videoBuffer, 1, &timing, &returnCount);
                CMTime time = timing.presentationTimeStamp;
                time = CMTimeAdd(self.currentVideoStartTime, time);
                
                NSTimeInterval timeInterval = CMTimeGetSeconds(time);
                
                if(self.maximumVideoDuration > .0 && timeInterval > self.maximumVideoDuration)
                {
                    breakVideoDueToMaximumDuration = YES;
                }
                
                if(timeInterval > currentVideoProgress)
                {
                    currentVideoProgress = timeInterval;
                    [self reportProgress:(currentAudioProgress+currentVideoProgress)*.5f];
                }
                
                CVPixelBufferRef pBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(videoBuffer);
                if(pBuffer)
                {
                    BOOL didAppend = [self.inputAdaptor appendPixelBuffer:pBuffer withPresentationTime:time];
                    if(!didAppend)
                    {
                        [self reportError:[NSError errorWithDomain:@"internal" code:500 userInfo:nil] withMessage:@"Failed appending the video buffer"];
                        CFRelease(videoBuffer);
                        break;
                    }
                }
                else
                {
                    [self reportError:[NSError errorWithDomain:@"internal" code:500 userInfo:nil] withMessage:@"Could not get the pixel buffer"];
                    CFRelease(videoBuffer);
                    break;
                }
                CFRelease(videoBuffer);
                
            }
            else
            {
                self.currentVideoStartTime = CMTimeAdd(self.currentVideoStartTime, [self currentVideoInput].asset.duration);
                self.currentVideoComponentIndex++;
                if([self currentVideoInput] == nil)
                {
                    videoDone = YES;
                    [self.videoAssetWriter markAsFinished];
                }
                else
                {
                    [[self currentVideoInput] startReadingVideo];
                }
            }
            
            didInsert = YES;
        }
        
        if(audioDone && videoDone)
        {
            if(callback)
            {
                callback();
            }
            break;
        }
        
        if(didInsert == NO)
        {
            self.currentSampleSkipCount++;
            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:M_WAIT_INTERVAL(self.currentSampleSkipCount)];
            [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
            continue;
        }
        else if(self.currentSampleSkipCount)
        {
            [self reportSkipCountIncreased:self.currentSampleSkipCount];
            self.currentSampleSkipCount = 0;
        }
    }
}
- (void)beginConversion:(void (^)(void))finishedBlock
{
    dispatch_async(self.queue, ^{
        if(self.assetWriter.status != AVAssetWriterStatusWriting)
        {
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:self.currentVideoStartTime];
        }
        
        [[self currentAudioInput] startReadingAudio];
        [[self currentVideoInput] startReadingVideo];
        
        [self insertInputBuffersCallback:^{
            if(finishedBlock)
            {
                finishedBlock();
            }
        }];
    });
}

- (void)resampleVideo
{
    [self clearOutputPath];
    self.currentAudioComponentIndex = 0;
    self.currentVideoComponentIndex = 0;

    [self loadInputData:^(NSArray *assets) {
        CMTime overallTime = kCMTimeZero;
        for(DLBSegmentedVideoConverterAsset *asset in assets)
        {
            overallTime = CMTimeAdd(overallTime, asset.duration);
        }
        self.inputTime = overallTime;
        self.inputDuration = (NSTimeInterval)CMTimeGetSeconds(overallTime);
        
        self.currentVideoStartTime = CMTimeMake(0, self.inputTime.timescale);
        self.currentAudioStartTime = CMTimeMake(0, self.inputTime.timescale);
        [self prepareInputComponents];
        [self prepareOutputComponents];
        [self beginConversion:^{
            [self.assetWriter finishWritingWithCompletionHandler:^{
                [self reportConversionDone];
            }];
        }];
    }];
}

- (void)reportConversionDone
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate segmentedVideoConverter:self finishedConversionTo:self.outputURL];
    });
}
- (void)reportError:(NSError *)error withMessage:(NSString *)message
{
    if(error)
    {
        if([self.delegate respondsToSelector:@selector(videoEditorController:didFailWithError:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate segmentedVideoConverter:self encounteredIssue:error message:message];
            });
        }
        else
        {
            NSLog(@"[ERROR](Video converter) %@", message);
        }
    }
}
- (void)reportProgress:(NSTimeInterval)progress
{
    if(self.inputDuration > .0f)
    {
        if([self.delegate respondsToSelector:@selector(segmentedVideoConverter:updatedProgress:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate segmentedVideoConverter:self updatedProgress:((CGFloat)(progress/self.inputDuration))];
            });
        }
        else
        {
            NSLog(@"Conversion progress updated: %g", ((CGFloat)(progress/self.inputDuration)));
        }
    }
}
- (void)reportSkipCountIncreased:(NSInteger)count
{
    if([self.delegate respondsToSelector:@selector(segmentedVideoConverter:reportsLagLevel:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate segmentedVideoConverter:self reportsLagLevel:count];
        });
    }
    else
    {
        NSLog(@"Lag level: %d", (int)count);
    }
}

@end
