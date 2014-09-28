//
//  BMViewController.m
//  UITableViewTest
//
//  Created by wangbaoxiang on 13-4-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "BMViewController.h"

@interface BMViewController ()

@end

@implementation BMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView *table  = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 60, 480)];
    table.backgroundColor = [UIColor whiteColor];
    [table.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    table.transform = CGAffineTransformMakeRotation(M_PI/-2);
    table.showsVerticalScrollIndicator = NO;
    table.frame = CGRectMake(0, 60, 320, 60);
    table.rowHeight = 60.0;
    NSLog(@"%f,%f,%f,%f",table.frame.origin.x,table.frame.origin.y,table.frame.size.width,table.frame.size.height);
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    [table release];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 16;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor redColor];
        cell.textLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"--------->%d",indexPath.row);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
