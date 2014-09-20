//
//  BackupLogoView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-20.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupLogoView.h"

@implementation BackupLogoView

+ (BackupLogoView *)view
{
    UIImage *image = [UIImage imageNamed:@"BackupLogo.png"];
    return [[BackupLogoView alloc] initWithImage:image];
}

@end
