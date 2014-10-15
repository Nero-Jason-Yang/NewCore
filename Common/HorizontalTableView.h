//
//  HorizontalTableView.h
//  HorizontalTable
//
//  Created by Jason Yang on 14-10-15.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HorizontalTableView;
@class HorizontalTableViewCell;

@protocol HorizontalTableViewDataSource <NSObject>
@required
- (NSInteger)tableViewNumberOfCells:(HorizontalTableView *)tableView;
- (HorizontalTableViewCell *)tableView:(HorizontalTableView *)tableView cellAtIndex:(NSInteger)index;
@optional
- (CGFloat)tableView:(HorizontalTableView *)tableView widthForCellAtIndex:(NSInteger)index;
@end

@protocol HorizontalTableViewDelegate <NSObject>
@optional
- (void)tableView:(HorizontalTableView *)tableView didSelectCellAtIndex:(NSInteger)index;
@end

@interface HorizontalTableView : UIView
@property (nonatomic,weak) id<HorizontalTableViewDataSource> dataSource;
@property (nonatomic,weak) id<HorizontalTableViewDelegate> delegate;
@property (nonatomic) BOOL showsHorizontalScrollIndicator; // default YES. show indicator while we are tracking. fades out after tracking
@property (nonatomic) BOOL allowsSelection;
@property (nonatomic) CGFloat cellDefaultWidth;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *separatorColor;
@property (nonatomic) UIEdgeInsets separatorInset;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyle;
@property (nonatomic) BOOL hideTailSeparator;
@property (nonatomic) BOOL middleCellsIfPossible;
@property BOOL scrollEnabled;
- (HorizontalTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)deselectCellAtIndex:(NSInteger)indexPath animated:(BOOL)animated;
- (NSInteger)indexForSelectedCell; // -1 means not found.
@end

@interface HorizontalTableViewCell : UIView
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic,readonly) NSString *reuseIdentifier;
@property (nonatomic,readonly) UILabel *textLabel;
@property (nonatomic,readonly) UIView *contentView;
@end
