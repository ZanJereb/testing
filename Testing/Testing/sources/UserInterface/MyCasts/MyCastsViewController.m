//
//  MyCastsViewController.m
//  Testing
//
//  Created by Zan on 2/9/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "MyCastsViewController.h"
#import "MyCastTableViewCell.h"
#import "Cast.h"

@interface MyCastsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *items;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *castCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelCountLabel;



@end

@implementation MyCastsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [Cast fetchAllCasts:^(NSArray *casts) {
        [self injectCasts:casts];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)injectCasts:(NSArray *)casts
{
    self.items = casts;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return  UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height * 0.5f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitMyCasts:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}
- (IBAction)optionsPressed:(id)sender
{
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"my casts" bundle:nil] instantiateViewControllerWithIdentifier:@"add Cast"];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"header" forIndexPath:indexPath];
    }
    else
    {
        MyCastTableViewCell *castCell = [tableView dequeueReusableCellWithIdentifier:@"cast" forIndexPath:indexPath];
        castCell.cast = self.items[indexPath.row-1];
        cell = castCell;
        
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? 50.0f : 76.0f;
}

@end
