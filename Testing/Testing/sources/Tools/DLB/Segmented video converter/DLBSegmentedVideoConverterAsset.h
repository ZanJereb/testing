//
//  DLBSegmentedVideoConverterAsset.h
//  Outcast
//
//  Created by Matic Oblak on 5/27/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

@import AVFoundation;


@interface DLBSegmentedVideoConverterAsset : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, readonly) AVAsset *asset;
@property (nonatomic, readonly) CMTime duration;
@property (nonatomic, readonly) NSTimeInterval durationInSeconds;
@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, readonly) NSArray *videoTracks;
@property (nonatomic, readonly) NSArray *audioTracks;
@property (nonatomic, readonly) CGSize videoSize;
@property (nonatomic, readonly) CGAffineTransform transform;

- (instancetype)initWithURL:(NSURL *)URL;
- (void)loadBasicData:(void (^)(BOOL succeeded))callback;

@end
