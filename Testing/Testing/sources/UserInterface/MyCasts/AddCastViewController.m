//
//  AddCastViewController.m
//  Testing
//
//  Created by Zan on 2/11/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "DLBSegmentedVideoConverter.h"
#import "AddCastViewController.h"
#import "ProgresOverLay.h"
#import "OUTAWSHandler.h"
@import MediaPlayer;
@import MobileCoreServices;


@interface AddCastViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, DLBSegmentedVideoConverterDelegate>
@property (nonatomic, strong) NSURL *videoPath;
@property (nonatomic, strong) MPMoviePlayerController *player;
@property (nonatomic, strong) DLBSegmentedVideoConverter *converter;
@property (nonatomic, strong) ProgresOverLay *overlay;
@property (nonatomic, strong) NSString *uniqueId;


@end

@implementation AddCastViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
- (IBAction)startRecording:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.videoPath = [info objectForKey:@"UIImagePickerControllerMediaURL"];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self showOverlay];
    
    self.converter = [[DLBSegmentedVideoConverter alloc] init];
    self.converter.inputURLs = @[self.videoPath];
    self.converter.outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"video.mp4"]];
    self.converter.delegate = self;
    [self.converter resampleVideo];
}

- (void)segmentedVideoConverter:(DLBSegmentedVideoConverter *)sender finishedConversionTo:(NSURL *)outputPath
{
    
    self.uniqueId= [[NSUUID UUID] UUIDString];
    [[OUTAWSHandler sharedInstance] uploadVideo:outputPath.path withUUID:self.uniqueId name:@"video.mp4" progressCallback:^(CGFloat progress, BOOL finished, NSError *error, BOOL *cancel) {
        if(finished)
        {
            [self hideOverlay];
        }
    }];
}

- (IBAction)previewVideo:(id)sender
{
    
    MPMoviePlayerViewController * controler = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoPath];
    
    [self presentViewController:controler animated:YES completion:nil];
}

- (void)showOverlay
{
    if(self.overlay == nil)
    {
        self.overlay = [ProgresOverLay presentOnView:self.view];
    }
}

- (void)hideOverlay
{
    [self.overlay dismiss];
    self.overlay = nil;
}
@end
