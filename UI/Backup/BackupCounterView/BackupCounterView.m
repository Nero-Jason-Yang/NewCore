//
//  BackupCounterView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupCounterView.h"
#import "HorizontalTableView.h"

@interface BackupCounterView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@end

@implementation BackupCounterView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[HorizontalTableView alloc] initWithFrame:self.frame];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 120;
        [self addSubview:tableView];
        self.tableView = tableView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect tableFrame = CGRectZero;
    tableFrame.size = self.frame.size;
    self.tableView.frame = tableFrame;
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
        cell = [[HorizontalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor redColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        label.text = @"ABC";
        [cell addSubview:label];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

@end
