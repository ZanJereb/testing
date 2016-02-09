//
//  MyCastsViewController.m
//  Testing
//
//  Created by Zan on 2/9/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "MyCastsViewController.h"

@interface MyCastsViewController ()

@end

@implementation MyCastsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitMyCasts:(id)sender {
    [self dismissViewControllerAnimated:NO completion:Nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
