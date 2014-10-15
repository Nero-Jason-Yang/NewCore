//
//  BackupCounterView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupCounterView.h"
#import "BackupCounterCell.h"

@interface BackupCounterView () <HorizontalTableViewDataSource, HorizontalTableViewDelegate>
@property (nonatomic) HorizontalTableView *tableView;
@end

@implementation BackupCounterView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[HorizontalTableView alloc] initWithFrame:self.frame];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorInset = UIEdgeInsetsMake(12, 0, 12, 0);
        //self.tableView.allowsSelection = NO;
        self.tableView.cellDefaultWidth = 100;
        self.tableView.hideTailSeparator = YES;
        //self.tableView.scrollEnabled = NO;
        self.tableView.middleCellsIfPossible = YES;
        [self addSubview:self.tableView];
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

- (NSInteger)tableViewNumberOfCells:(HorizontalTableView *)tableView
{
    return 3;
}

- (HorizontalTableViewCell *)tableView:(HorizontalTableView *)tableView cellAtIndex:(NSInteger)index {
    static NSString *identifier = @"cell";
    BackupCounterCell *cell = (BackupCounterCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BackupCounterCell alloc] initWithReuseIdentifier:identifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.title = @(index).description;
    switch (index) {
        case 0:
            cell.subtitle = @"ALL PHOTOS";
            break;
            
        case 1:
            cell.subtitle = @"ALL VIDEOS";
            break;
            
        default:
            cell.subtitle = @"ALL MUSICS";
            break;
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
