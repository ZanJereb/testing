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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitMyCasts:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
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
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

@end
