//
//  DLBSegmentedVideoConverterAsset.m
//  Outcast
//
//  Created by Matic Oblak on 5/27/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import "DLBSegmentedVideoConverterAsset.h"

@interface DLBSegmentedVideoConverterAsset()

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic) CMTime duration;
@property (nonatomic) BOOL loaded;
@property (nonatomic) NSArray *videoTracks;
@property (nonatomic) NSArray *audioTracks;
@property (nonatomic) CGSize videoSize;
@property (nonatomic) CGAffineTransform transform;

@end

@implementation DLBSegmentedVideoConverterAsset

- (instancetype)initWithURL:(NSURL *)URL
{
    if((self = [super init]))
    {
        self.url = URL;
    }
    return self;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    self.asset = [AVAsset assetWithURL:url];
}

- (void)loadBasicData:(void (^)(BOOL succeeded))callback
{
    NSArray *keys = @[@"playable", @"tracks", @"duration"];
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        self.duration = self.asset.duration;
        
        [self loadTrackData];
        
        self.loaded = YES;
        
        if(callback)
        {
            callback(YES);
        }
    }];
}
- (void)loadTrackData
{
    NSArray *tracks = self.asset.tracks;
    NSMutableArray *videoTracks = [[NSMutableArray alloc] init];
    NSMutableArray *audioTracks = [[NSMutableArray alloc] init];
    for(AVAssetTrack *track in tracks)
    {
        if([track.mediaType isEqualToString:AVMediaTypeVideo])
        {
            [videoTracks addObject:track];
            self.transform = [track preferredTransform];
        }
        else if([track.mediaType isEqualToString:AVMediaTypeAudio])
        {
            [audioTracks addObject:track];
        }
        
    }
    self.videoTracks = videoTracks;
    self.audioTracks = audioTracks;
    CGSize size = CGSizeZero;
    
    for(AVAssetTrack *track in tracks)
    {
        CGSize targetSize = track.naturalSize;
        if(targetSize.width > size.width)
        {
            size = targetSize;
        }
    }
    if(size.width > self.videoSize.width)
    {
        self.videoSize = size;
    }
}
- (NSTimeInterval)durationInSeconds
{
    return (NSTimeInterval)CMTimeGetSeconds(self.duration);
}
@end
