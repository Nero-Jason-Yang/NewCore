//
//  BackupSwitch.h
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BackupSwitchState) {
    BackupSwitchStateOff,
    BackupSwitchStateDone,
    BackupSwitchStateRunning,
    BackupSwitchStatePending,
};

@interface BackupSwitch : UIView
@property (nonatomic) BOOL on;
@property (nonatomic) BackupSwitchState state;
@end
