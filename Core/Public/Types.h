//
//  Typedef.h
//  NewCore
//
//  Created by Yang Jason on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@class File;

#pragma mark - notifications

#define Notification_LoginRequired @"LoginRequired"


#pragma mark - structs

typedef enum : uint8_t {
    AccountState_Unauthorized = 0,
    AccountState_Logouted,
    AccountState_Logining,
    AccountState_LoginFailed,
    AccountState_LoginSucceeded,
} AccountState;
