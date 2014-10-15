//
//  HorizontalTableView.m
//  HorizontalTable
//
//  Created by Jason Yang on 14-10-15.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "HorizontalTableView.h"

UIEdgeInsets UIEdgeInsetsRotateClockwise(UIEdgeInsets value) {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    inset.left = value.top;
    inset.top = value.right;
    inset.right = value.bottom;
    inset.bottom = value.left;
    return inset;
}

UIEdgeInsets UIEdgeInsetsRotateAnticlockwise(UIEdgeInsets value) {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    inset.top = value.left;
    inset.right = value.top;
    inset.bottom = value.right;
    inset.left = value.bottom;
    return inset;
}

@interface HorizontalTableView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic,readonly) NSMutableDictionary *freeCells;
@property (nonatomic) NSInteger numberOfCells; // used for finding footer cell.
@end

@interface HorizontalTableViewCellShell : UITableViewCell
@property (nonatomic,weak) HorizontalTableViewCell *cell;
@property (nonatomic) BOOL shouldHideSeparator;
@end

@implementation HorizontalTableView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        self.tableView.transform = CGAffineTransformMakeRotation(M_PI/-2);
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self addSubview:self.tableView];
        
        _cellDefaultWidth = self.tableView.rowHeight;
        _freeCells = [NSMutableDictionary dictionary];
        
        self.tableView.tableHeaderView = [[UIView alloc] init];
        self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = [[UIView alloc] init];
        self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (BOOL)showsHorizontalScrollIndicator {
    return self.tableView.showsVerticalScrollIndicator;
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    self.tableView.showsVerticalScrollIndicator = showsHorizontalScrollIndicator;
}

- (BOOL)allowsSelection {
    return self.tableView.allowsSelection;
}

- (void)setAllowsSelection:(BOOL)allowsSelection {
    self.tableView.allowsSelection = allowsSelection;
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
    return UIEdgeInsetsRotateClockwise(self.tableView.separatorInset);
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset {
    self.tableView.separatorInset = UIEdgeInsetsRotateAnticlockwise(separatorInset);
}

- (UITableViewCellSeparatorStyle)separatorStyle {
    return self.tableView.separatorStyle;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
    self.tableView.separatorStyle = separatorStyle;
}

- (void)setMiddleCellsIfPossible:(BOOL)middleCellsIfPossible {
    if (_middleCellsIfPossible != middleCellsIfPossible) {
        _middleCellsIfPossible = middleCellsIfPossible;
        [self setNeedsLayout];
    }
}

- (BOOL)scrollEnabled {
    return self.tableView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.tableView.scrollEnabled = scrollEnabled;
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

- (void)deselectCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:animated];
}

- (NSInteger)indexForSelectedCell {
    NSIndexPath *selected = self.tableView.indexPathForSelectedRow;
    if (selected) {
        return selected.row;
    }
    return -1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    self.tableView.frame = frame;
    
    if (self.middleCellsIfPossible) {
        CGFloat width = 0.0;
        for (NSInteger i = 0; i < self.numberOfCells; i ++) {
            width += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            if (width >= frame.size.width) {
                return;
            }
        }
        
        width = (frame.size.width - width) / 2;
        frame = self.tableView.tableHeaderView.frame;
        frame.size.height = width;
        self.tableView.tableHeaderView.frame = frame;
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    }
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.numberOfCells = [self.dataSource tableViewNumberOfCells:self];
    return self.numberOfCells;
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
    
    if (self.hideTailSeparator && indexPath.row + 1 == self.numberOfCells) {
        shell.shouldHideSeparator = YES;
    } else {
        shell.shouldHideSeparator = NO;
    }
    
    shell.cell = cell;
    return shell;
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(tableView:widthForCellAtIndex:)]) {
        return [self.dataSource tableView:self widthForCellAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectCellAtIndex:)]) {
        [self.delegate tableView:self didSelectCellAtIndex:indexPath.row];
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
    
    // for separator view.
    for (UIView *separatorView in self.subviews) {
        if ([NSStringFromClass(separatorView.class) isEqualToString:@"_UITableViewCellSeparatorView"]) {
            separatorView.hidden = self.shouldHideSeparator;
            break;
        }
    }
}

@end
