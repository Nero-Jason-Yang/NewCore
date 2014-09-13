//
//  UIView+Common.m
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "UIView+Common.h"

@implementation UIView (Common)

+ (UIView *)topLogoView
{
    UIImage *image = [UIImage imageNamed:@"top-logo.png"];
    return [[UIImageView alloc] initWithImage:image];
}

@end
