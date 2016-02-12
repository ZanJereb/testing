//
//  DLBSegmentedVideoConverter.h
//  Outcast
//
//  Created by Matic Oblak on 5/27/15.
//  Copyright (c) 2015 D&#183;Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@class DLBSegmentedVideoConverter;

@protocol DLBSegmentedVideoConverterDelegate<NSObject>

- (void)segmentedVideoConverter:(DLBSegmentedVideoConverter *)sender finishedConversionTo:(NSURL *)outputPath;
@optional
- (void)segmentedVideoConverter:(DLBSegmentedVideoConverter *)sender encounteredIssue:(NSError *)error message:(NSString *)message;
- (void)segmentedVideoConverter:(DLBSegmentedVideoConverter *)sender updatedProgress:(CGFloat)progress;
- (void)segmentedVideoConverter:(DLBSegmentedVideoConverter *)sender reportsLagLevel:(NSInteger)level;

@end


@interface DLBSegmentedVideoConverter : NSObject

@property (nonatomic, weak) id<DLBSegmentedVideoConverterDelegate> delegate;

@property (nonatomic, strong) NSArray *inputURLs;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic) CGSize outputVideoSize;
@property (nonatomic) CGFloat bitRateScale;
@property (nonatomic) BOOL useJPEGCodec;
@property (nonatomic) CGFloat JPEGCodecQuality;
@property (nonatomic) NSInteger keyFrameSkipCount;
@property (nonatomic) NSTimeInterval maximumVideoDuration;

- (void)resampleVideo;


@end
