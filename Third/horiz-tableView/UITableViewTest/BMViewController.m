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
    
    CGRect frame = self.view.frame;
    
    UITableView *table  = [[UITableView alloc] initWithFrame:frame];
    table.backgroundColor = [UIColor greenColor];
    table.transform = CGAffineTransformMakeRotation(M_PI/-2);
    table.showsVerticalScrollIndicator = NO;
    
    table.frame = CGRectMake(0, 120, frame.size.width, 60);
    table.rowHeight = 120.0;
    table.clipsToBounds = NO;
    
    //table.scrollEnabled = NO;
    
    NSLog(@"%f,%f,%f,%f",table.frame.origin.x,table.frame.origin.y,table.frame.size.width,table.frame.size.height);
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    [table release];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        table.frame = CGRectMake(0, 130, frame.size.width-10, 70);
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor redColor];
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        label.text = @"ABC";
        [cell addSubview:label];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellFrame = cell.frame;
    CGRect textFrame = cell.textLabel.frame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"--------->%d",indexPath.row);
}

@end
