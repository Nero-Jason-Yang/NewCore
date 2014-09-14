//
//  BackupViewController.m
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupViewController.h"
#import "TabBarController.h"
#import "BackupSwitch.h"
#import "Common.h"

@interface BackupViewController ()

@end

@implementation BackupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButtonPress:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView topLogoView]];
    self.navigationController.navigationBar.barTintColor = [SkinScheme currentSkinScheme].navBarBackgroundColor;
    self.navigationController.navigationBar.tintColor = [SkinScheme currentSkinScheme].navBarForegroundColor;
    
    self.tableView.allowsSelection = NO;
    
    // separator line
    UIEdgeInsets edgeInsets = self.tableView.separatorInset;
    edgeInsets.right = edgeInsets.left;
    self.tableView.separatorInset = edgeInsets;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRightButtonPress:(id)sender
{
    TabBarController *vc = [[TabBarController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Hello";
        BackupSwitch *view = [[BackupSwitch alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        [cell addSubview:view];
    }
    else {
        cell.textLabel.text = @(indexPath.row).description;
    }
    return cell;
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 120;
    }
    else {
        return tableView.rowHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (0 == section) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return nil;
}

@end
