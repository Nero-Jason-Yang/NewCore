//
//  CoreError.h
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : int32_t {
    // unknown error, not handled.
    // reason: error code is unknown or not implemented, a message got from response data.
    // handle: ui can show the message to user.
    //       : log with context, and it should be resolved later.
    Error_Unknown = 0,
    
    // unexpected error, not handled.
    // reason: may be caused by invalid response data, or data format changed but we don't known.
    // handle: ui can only say sorry to user;
    //       : log with context, and it should be resolved later.
    Error_Unexpected,
    
    // network unavailable.
    // reason: wifi, wwan, lan,... not connected, proxy or route unavailable.
    // handle: for backup, will continue automatically when network resume to be available;
    //       : for browsing, tell user to try again later manually.
    Error_NetworkUnavailable,
    
    // service unavailable.
    // reason: server maintenance.
    // handle: tell user to try again later manually.
    Error_ServiceUnavailable,
    
    // request timeout.
    // reason: network speed is slow or network status is not stable.
    // handle: caller should try again immediately.
    Error_Timeout,
    
    // account unauthorized.
    // reason: not login, or revoked by remote, or session expired.
    // handle: ui should pop up a dialog to let user login with password.
    Error_Unauthorized,
    
    // operation failed.
    // reason: multiple, with friendly message.
    // handle: ui should alert user with the message.
    Error_Failed,
    
} ErrorCode;

typedef enum : int16_t {
    Error_Register_NicknameMissing,
    Error_Register_EmailMissing,
    Error_Register_CountryMissing,
    Error_Register_SecurityCodeMissing,
    Error_Register_PasswordMissing,
    Error_Register_ChecksumMissing,
    Error_Register_ActivateFailed,
    Error_Register_AlreadyExisted,
    
    Error_Login_DataMissing,
    Error_Login_NicknameMissing,
    Error_Login_PasswordMissing,
    Error_Login_AccountInactived,
    Error_Login_EmailPasswordMismatched,
    Error_Login_TOSChanged,
    Error_Login_NotFound,
    
    Error_PasswordChange_OldPasswordMissing,
    Error_PasswordChange_NewPasswordMissing,
    Error_PasswordChange_NewPasswordTooShort,
    Error_PasswordChange_OldPasswordIncorrect,
    Error_PasswordChange_EmailMissing,
    Error_PasswordChange_NotFound,
    Error_PasswordChange_Failed,
    
    Error_PasswordRenew_EmailMissing,
    Error_PasswordRenew_SendFailed,
    Error_PasswordRenew_NotEnoughTime,
    Error_PasswordRenew_Failed,
    
    Error_AcceptTOS_EmailMissing,
    Error_AcceptTOS_TOSMissing,
    Error_AcceptTOS_TOSInvalid,
    Error_AcceptTOS_TOSDateOld,
    Error_AcceptTOS_NotFound,
    Error_AcceptTOS_Failed,
} ErrorSubCode;

@interface Error : NSError
+ (instancetype)errorWithCode:(ErrorCode)code;
+ (instancetype)errorWithCode:(ErrorCode)code message:(NSString *)message;
+ (instancetype)errorWithCode:(ErrorCode)code message:(NSString *)message reason:(NSString *)reason;
@end
