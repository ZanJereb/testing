//
//  ProgresOverLay.m
//  Testing
//
//  Created by Zan on 2/12/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "ProgresOverLay.h"

@interface ProgresOverLay ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation ProgresOverLay

+ (ProgresOverLay *)presentOnView:(UIView *)view
{
    ProgresOverLay *progres = [[ProgresOverLay alloc] initWithFrame:view.bounds];
    
    progres.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    progres.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    progres.activityView.center = CGPointMake(progres.frame.size.width * 0.5f, progres.frame.size.height * 0.5f);
    [progres addSubview:progres.activityView];
    
    [progres.activityView startAnimating];
    
    [view addSubview:progres];
    
    progres.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    progres.alpha = 0.0f;
    
    [UIView animateWithDuration:0.5 animations:^{
        progres.alpha = 1.0f;
        progres.transform = CGAffineTransformIdentity;
        
    }];
    
    return progres;
}
- (void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.activityView stopAnimating];
    }];
    
}


@end
