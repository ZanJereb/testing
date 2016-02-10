//
//  MyCastsViewController.m
//  Testing
//
//  Created by Zan on 2/9/16.
//  Copyright © 2016 Zan. All rights reserved.
//

#import "MyCastsViewController.h"

@interface MyCastsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *items;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;


@end

@implementation MyCastsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSMutableArray *array=[[NSMutableArray alloc] init];
    for(int i=0;i<10;i++)
        {
            [array addObject:[NSString stringWithFormat:@"Item: %d", i+1]];
        }
    self.items=array;
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
    static BOOL small = true;
    [self.view layoutIfNeeded];
    small = !small;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = self.items[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

@end
