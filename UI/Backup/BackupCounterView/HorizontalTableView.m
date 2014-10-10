//
//  HorizontalTableView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView ()
@property (nonatomic,readonly) UIView *nilTableFooterView;
@end

@implementation HorizontalTableView

- (id)init {
    if (self = [super init]) {
        [self privateInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self privateInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self privateInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self privateInit];
    }
    return self;
}

- (void)privateInit {
    self.transform = CGAffineTransformMakeRotation(M_PI/-2);
    self.showsVerticalScrollIndicator = NO;
    _nilTableFooterView = [[UIView alloc] init];
    _nilTableFooterView.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:_nilTableFooterView];
}

- (void)setTableFooterView:(UIView *)tableFooterView {
    if (!tableFooterView) {
        tableFooterView = self.nilTableFooterView;
    }
    [super setTableFooterView:tableFooterView];
}

- (UIView *)tableFooterView {
    UIView *tableFooterView = [super tableFooterView];
    return (tableFooterView == self.nilTableFooterView) ? nil : tableFooterView;
}

@end

@implementation HorizontalTableViewCell

- (id)init {
    if (self = [super init]) {
        [self privateInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self privateInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self privateInit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self privateInit];
    }
    return self;
}

- (void)privateInit {
    self.transform = CGAffineTransformMakeRotation(M_PI/2);
}

- (void)setFrame:(CGRect)frame {
    UIView *superview = self.superview;
    if (superview) {
        CGRect superframe = superview.frame;
        if (frame.size.width > superframe.size.width) {
            frame.size.width = superframe.size.width;
        }
        //if (frame.size.height > superframe.size.height) {
        //    frame.size.height = superframe.size.height;
        //}
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // for separator view.
    for (UIView *separatorView in self.subviews) {
        if ([NSStringFromClass(separatorView.class) isEqualToString:@"_UITableViewCellSeparatorView"]) {
            separatorView.hidden = self.separatorHidden;
            if (!separatorView.hidden) {
                CGRect frame = separatorView.frame;
                frame.size.width = 0.5;
                frame.origin.x = self.frame.size.height - frame.size.width;
                
                UIEdgeInsets insets = self.separatorInset;
                if (insets.top > 0 || insets.bottom > 0) {
                    frame.origin.y = insets.top;
                    CGFloat height = self.frame.size.width - insets.top - insets.bottom;
                    frame.size.height = (height > 0) ? height : 0;
                } else {
                    frame.origin.y = insets.left;
                    CGFloat height = self.frame.size.width - insets.left - insets.right;
                    frame.size.height = (height > 0) ? height : 0;
                }
                
                separatorView.frame = frame;
            }
        }
    }
}

@end
