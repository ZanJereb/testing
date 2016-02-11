//
//  MyCastTableViewCell.m
//  Testing
//
//  Created by Zan on 2/10/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "MyCastTableViewCell.h"
#import "Cast.h"

@interface MyCastTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *tumbNailImageView;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel;

@end

@implementation MyCastTableViewCell

- (IBAction)infoButton:(id)sender
{
    
}

- (void)setCast:(Cast *)cast
{
    _cast=cast;
    self.currentLocationLabel.text = cast.location;
    self.quoteLabel.text = cast.title;
    self.postTimeLabel.text = cast.timeStamp;
}

@end
