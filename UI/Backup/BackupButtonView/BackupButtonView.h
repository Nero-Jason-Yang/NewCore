//
//  BackupButtonView.h
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BackupButtonState) {
    BackupButtonStateOff,
    BackupButtonStateDone,
    BackupButtonStateRunning,
    BackupButtonStatePending,
};

@interface BackupButtonView : UIView
@property (nonatomic) BOOL on;
@property (nonatomic) BackupButtonState state;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) UIColor *buttonColor;
@property (nonatomic) UIColor *arrowColor;
@property (nonatomic) CGFloat margin; // >= 1 means points, < 1 means percentage.
@end
