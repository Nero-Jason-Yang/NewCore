//
//  BackupCounterView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupCounterView.h"
#import "BackupCounterCell.h"

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
        tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
        //tableView.allowsSelection = NO;
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BackupCounterCell *cell = (BackupCounterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BackupCounterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.title = @(indexPath.row).description;
    switch (indexPath.row) {
        case 0:
            cell.subtitle = @"ALL PHOTOS";
            break;
            
        case 1:
            cell.subtitle = @"ALL VIDEOS";
            break;
            
        default:
            cell.subtitle = @"HELLO";
            break;
    }
    
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] - 1) {
        cell.separatorHidden = YES;
        //cell.separatorInset = UIEdgeInsetsMake(0, CGFLOAT_MAX, 0, 0); // another way to hide separator
    } else {
        cell.separatorHidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // TODO
    // ...
    // to perform some action.
}

@end
