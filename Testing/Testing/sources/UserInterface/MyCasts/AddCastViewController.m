//
//  AddCastViewController.m
//  Testing
//
//  Created by Zan on 2/11/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "AddCastViewController.h"
@import MediaPlayer;
@import MobileCoreServices;

@interface AddCastViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSURL *videoPath;
@property (nonatomic, strong) MPMoviePlayerController *player;


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

}

- (IBAction)previewVideo:(id)sender
{
    
    MPMoviePlayerViewController * controler = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoPath];
    
    [self presentViewController:controler animated:YES completion:nil];
}

@end
