//
//  BackupCounterCell.m
//  NewCore
//
//  Created by Jason Yang on 14-9-30.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupCounterCell.h"

#define NumOfLabels           2
#define TitleFontName         @"HelveticaNeue-Light"
#define SubtitleFontName      @"HelveticaNeue-Medium"
#define BaseViewHeight       60.0
#define BaseLineSpace         2.0
#define BaseTitleFontSize    20.0
#define BaseSubtitleFontSize  9.0

@interface BackupCounterCell ()
@property (nonatomic,readonly) UILabel *titleLabel;
@property (nonatomic,readonly) UILabel *subtitleLabel;
@end

@implementation BackupCounterCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self privateInitWithFrame:frame];
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self privateInitWithFrame:self.frame];
    }
    return self;
}

- (void)privateInitWithFrame:(CGRect)frame
{
    frame.origin = CGPointZero;
    
    {// init title
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont fontWithName:TitleFontName size:BaseTitleFontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"";
        [self.contentView addSubview:label];
        _titleLabel = label;
    }
    
    {// init subtitle
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont fontWithName:SubtitleFontName size:BaseSubtitleFontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"";
        [self.contentView addSubview:label];
        _subtitleLabel = label;
    }
    
    [self privateLayoutSubviews];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title ? title : @"";
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle ? subtitle : @"";
}

- (NSString *)subtitle
{
    return self.subtitleLabel.text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self privateLayoutSubviews];
}

- (void)privateLayoutSubviews
{
    CGSize contentSize = self.contentView.frame.size;
    CGFloat scale = contentSize.height / BaseViewHeight;
    CGFloat lineSpace = BaseLineSpace * scale;
    CGFloat fontSizes[2] = {BaseTitleFontSize * scale, BaseSubtitleFontSize * scale};
    UILabel *  labels[2] = {self.titleLabel, self.subtitleLabel};
    CGSize boundSizes[2] = {};
    
    // calculate bound size of each label.
    for (int i = 0; i < 2; i ++) {
        UILabel *label = labels[i];
        label.font = [label.font fontWithSize:fontSizes[i]];
        boundSizes[i] = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    }
    
    // calculate bound size of group for all labels.
    CGSize groupBoundSize = boundSizes[0];
    for (int i = 1; i < 2; i ++) {
        if (groupBoundSize.width < boundSizes[i].width) {
            groupBoundSize.width = boundSizes[i].width;
        }
        groupBoundSize.height += lineSpace;
        groupBoundSize.height += boundSizes[i].height;
    }
    
    // calculate and set frame for all labels.
    CGRect frame = CGRectZero;
    frame.origin.y = (contentSize.height - groupBoundSize.height) / 2.0;
    frame.size.width = contentSize.width;
    for (int i = 0; i < 2; i ++) {
        frame.size.height = boundSizes[i].height;
        labels[i].frame = frame;
        frame.origin.y += frame.size.height;
        frame.origin.y += lineSpace;
    }
}

@end
