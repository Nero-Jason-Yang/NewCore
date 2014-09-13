//
//  SkinScheme.m
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "SkinScheme.h"

static SkinScheme *instance;

@implementation SkinScheme

+ (SkinScheme *)currentSkinScheme
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SkinScheme alloc] init];
        instance.navBarBackgroundColor = instance.tabBarForegroundColor = [self greenColor];
        instance.navBarForegroundColor = instance.tabBarBackgroundColor = [UIColor whiteColor];
    });
    return instance;
}

+ (UIColor *)greenColor
{
    return [UIColor colorWithRed:32.0/255 green:151.0/255 blue:71.0/255 alpha:1];
}

+ (UIColor *)deepGreenColor
{
    return [UIColor colorWithRed:15.0/255 green:71.0/255 blue:34.0/255 alpha:1];
}

@end
