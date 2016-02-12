//
//  DLBSegmentedVideoConverterInput.h
//  Outcast
//
//  Created by Matic Oblak on 5/27/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

@import AVFoundation;
@class DLBSegmentedVideoConverterAsset;

@interface DLBSegmentedVideoConverterInput : NSObject

@property (nonatomic, readonly) DLBSegmentedVideoConverterAsset *asset;
@property (nonatomic, readonly) NSError *error;

- (instancetype)initWithAsset:(DLBSegmentedVideoConverterAsset *)asset;
- (BOOL)loadComponents;

- (CMSampleBufferRef)copyAudioBuffer;
- (CMSampleBufferRef)copyVideoBuffer;

- (void)startReadingAudio;
- (void)startReadingVideo;

@end
