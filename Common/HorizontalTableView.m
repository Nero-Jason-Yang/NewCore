//
//  HorizontalTableView.m
//  HorizontalTable
//
//  Created by Jason Yang on 14-10-15.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic,readonly) NSMutableDictionary *freeCells;
@end

@interface HorizontalTableViewCellShell : UITableViewCell
@property (nonatomic,weak) HorizontalTableViewCell *cell;
@end

@implementation HorizontalTableView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        self.tableView.transform = CGAffineTransformMakeRotation(M_PI/-2);
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self addSubview:self.tableView];
        
        _freeCells = [NSMutableDictionary dictionary];
        _cellDefaultWidth = self.tableView.rowHeight;
    }
    return self;
}

- (BOOL)showsHorizontalScrollIndicator {
    return [self.tableView showsVerticalScrollIndicator];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    [self.tableView setShowsVerticalScrollIndicator:showsHorizontalScrollIndicator];
}

- (UIColor *)backgroundColor {
    return self.tableView.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.tableView.backgroundColor = backgroundColor;
}

- (UIColor *)separatorColor {
    return [self.tableView separatorColor];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    [self.tableView setSeparatorColor:separatorColor];
}

- (UIEdgeInsets)separatorInset {
    UIEdgeInsets inset = self.tableView.separatorInset;
    UIEdgeInsets separatorInset = UIEdgeInsetsZero;
    separatorInset.left = inset.top;
    separatorInset.top = inset.right;
    separatorInset.right = inset.bottom;
    separatorInset.bottom = inset.left;
    return separatorInset;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    inset.top = separatorInset.left;
    inset.right = separatorInset.top;
    inset.bottom = separatorInset.right;
    inset.left = separatorInset.bottom;
    self.tableView.separatorInset = inset;
}

- (HorizontalTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    if (identifier) {
        NSMutableArray *cells = self.freeCells[identifier];
        if (cells) {
            id cell = cells.firstObject;
            if (cell) {
                [cells removeObjectAtIndex:0];
            }
            return cell;
        }
    }
    return nil;
}

- (void)enqueueReusableCell:(HorizontalTableViewCell *)cell {
    NSString *identifier = cell.reuseIdentifier;
    if (identifier) {
        NSMutableArray *cells = self.freeCells[identifier];
        if (!cells) {
            cells = [NSMutableArray array];
            [cells addObject:cell];
            self.freeCells[identifier] = cells;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    self.tableView.frame = frame;
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource tableViewNumberOfCells:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HorizontalTableViewCell *cell = [self.dataSource tableView:self cellAtIndex:indexPath.row];
    if (!cell) {
        return nil;
    }
    
    static NSString *identifier = @"shell";
    HorizontalTableViewCellShell *shell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!shell) {
        shell = [[HorizontalTableViewCellShell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    shell.cell = cell;
    return shell;
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:widthForCellAtIndex:)]) {
        return [self.delegate tableView:self widthForCellAtIndex:indexPath.row];
    }
    else {
        return [self cellDefaultWidth];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:HorizontalTableViewCellShell.class]) {
        HorizontalTableViewCellShell *shell = (HorizontalTableViewCellShell *)cell;
        if (shell.cell) {
            [self enqueueReusableCell:shell.cell];
            shell.cell = nil;
        }
    }
}

@end

@implementation HorizontalTableViewCell {
    UILabel *_textLabel;
    UIView *_contentView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super init]) {
        _reuseIdentifier = reuseIdentifier;
        
        CGRect frame = CGRectZero;
        frame.size.width = self.frame.size.height;
        frame.size.height = self.frame.size.width;
        _contentView = [[UIView alloc] initWithFrame:frame];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        _textLabel  = [[UILabel alloc] initWithFrame:frame];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectZero;
    frame.size.width = self.frame.size.height;
    frame.size.height = self.frame.size.width;
    if (_textLabel) {
        _textLabel.frame = frame;
    }
    if (_contentView) {
        _contentView.frame = frame;
    }
}

@end

@implementation HorizontalTableViewCellShell

- (void)setCell:(HorizontalTableViewCell *)cell {
    if (_cell) {
        _cell.transform = CGAffineTransformIdentity;
        [_cell removeFromSuperview];
    }
    if (cell) {
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self.contentView addSubview:cell];
    }
    _cell = cell;
}

- (void)setFrame:(CGRect)frame {
    UIView *superview = self.superview;
    if (superview) {
        CGRect superframe = superview.frame;
        if (frame.size.width > superframe.size.width) {
            frame.size.width = superframe.size.width;
        }
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectZero;
    frame.size = self.frame.size;
    self.cell.frame = frame;
}

@end
