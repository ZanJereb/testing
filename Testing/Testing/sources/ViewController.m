//
//  ViewController.m
//  Testing
//
//  Created by Zan on 2/9/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "ViewController.h"
#import "OUTAPIManager.h"
#import "User.h"
#import "MyCastsViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    indicator.center = CGPointMake(self.view.bounds.size.width*.5f, self.view.bounds.size.height*.5f);
    [self.view addSubview:indicator];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[OUTAPIManager sharedInstance] loginWithUserName:@"maticoblakltt2@gmail.com" password:@"maticdemo" callback:^(BOOL didLogin, NSError *error) {
        
        [[OUTAPIManager sharedInstance] performRequest:[OUTAPIRequest forEndpoint:EndpointPathMe ofType:APICallGet] withCallback:^(id responseObject, NSError *error, NSNumber *statusCode) {
            User *me = [[User alloc] initWithDescriptor:responseObject[@"item"]];
            NSLog(@"%@", me.profileName);
            UINavigationController *controller = [[UIStoryboard storyboardWithName:@"my casts" bundle:nil] instantiateViewControllerWithIdentifier:@"myCastNavigaton"];
            [controller.viewControllers[0] setUser:me];
            [self presentViewController:controller animated:NO completion:nil];
        }];
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
