//
//  BackupCounterView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-20.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupCounterView.h"

@implementation BackupCounterView
{
    BackupCounterCell *_photosCell;
    BackupCounterCell *_videosCell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = frame;
        rect.size.width /= 2;
        _photosCell = [[BackupCounterCell alloc] initWithFrame:rect];
        _photosCell.count = 200;
        _photosCell.title = @"ALL PHOTOS";
        [self addSubview:_photosCell];
        
        rect.origin.x += rect.size.width;
        _videosCell = [[BackupCounterCell alloc] initWithFrame:rect];
        _videosCell.count = 16;
        _videosCell.title = @"ALL VIDEOS";
        [self addSubview:_videosCell];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    rect.size = self.frame.size;
    rect.size.width /= 2;
    _photosCell.frame = rect;
    
    rect.origin.x += rect.size.width;
    _videosCell.frame = rect;
}

- (void)drawRect:(CGRect)rect
{
    if (rect.size.height <= 12) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    // top horizontal line
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    
    // middle vertical line
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width / 2, rect.origin.y + 6);
    CGContextAddLineToPoint(context, rect.origin.y + rect.size.width / 2, rect.origin.y + rect.size.height - 6);
    
    // bottom horizontal line
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
    CGContextStrokePath(context);
}

@end

@implementation BackupCounterCell
{
    UILabel *_countLabel;
    UILabel *_titleLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = frame;
        rect.size.height /= 2;
        _countLabel = [[UILabel alloc] initWithFrame:rect];
        _countLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countLabel];
        
        rect.origin.y += rect.size.height;
        _titleLabel = [[UILabel alloc] initWithFrame:rect];
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:9];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
    
}

- (void)setCount:(NSInteger)count
{
    _count = count;
    _countLabel.text = @(count).description;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize countSize = [_countLabel.text sizeWithAttributes:@{NSFontAttributeName:_countLabel.font}];
    CGSize titleSize = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}];
    
    CGRect rect = CGRectZero;
    rect.origin.y = (self.frame.size.height - countSize.height - titleSize.height) / 2;
    rect.size.width = self.frame.size.width;
    rect.size.height = countSize.height;
    _countLabel.frame = rect;
    
    rect.origin.y += rect.size.height;
    rect.size.height = titleSize.height;
    _titleLabel.frame = rect;
    
    /*
    CGRect rect = CGRectZero;
    rect.size = self.frame.size;
    rect.size.height /= 2;
    _countLabel.frame = rect;
    
    rect.origin.y += rect.size.height;
    _titleLabel.frame = rect;
     */
}

@end
