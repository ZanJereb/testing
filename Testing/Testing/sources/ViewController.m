//
//  ViewController.m
//  Testing
//
//  Created by Zan on 2/9/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)buttonMethod:(id)sender {
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"my casts" bundle:nil] instantiateViewControllerWithIdentifier:@"myCasts"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
