//
//  ProgresOverLay.h
//  Testing
//
//  Created by Zan on 2/12/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgresOverLay : UIView

+ (ProgresOverLay *)presentOnView:(UIView *)view;
- (void)dismiss;

@end
