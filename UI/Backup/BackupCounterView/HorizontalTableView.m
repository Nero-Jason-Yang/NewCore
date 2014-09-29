//
//  HorizontalTableView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "HorizontalTableView.h"

@implementation HorizontalTableView

- (id)init {
    if (self = [super init]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/-2);
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/-2);
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/-2);
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/-2);
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

@end

@implementation HorizontalTableViewCell

- (id)init {
    if (self = [super init]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    UIView *superview = self.superview;
    if (superview) {
        CGRect superframe = superview.frame;
        if (frame.size.width > superframe.size.width) {
            frame.size.width = superframe.size.width;
        }
        if (frame.size.height > superframe.size.height) {
            frame.size.height = superframe.size.height;
        }
    }
    [super setFrame:frame];
}

@end
