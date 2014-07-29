//
//  CoreError.h
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : int32_t {
    CoreError_Unknown = 0,
    CoreError_HostUnspecified,
    CoreError_NetworkNotAvailable,
    CoreError_ServiceUnavailable,
    CoreError_Unauthorized,
    CoreError_InvalidResponseData, // unexpected, the response data is invalid.
    
    CoreError_Login_DataMissing,
    CoreError_Login_NicknameMissing,
    CoreError_Login_PasswordMissing,
    CoreError_Login_AccountInactived,
    CoreError_Login_EmailPasswordMismatched,
    CoreError_Login_TOSChanged,
    CoreError_Login_NotFound,
    
    CoreError_Register_NicknameMissing,
    CoreError_Register_EmailMissing,
    CoreError_Register_CountryMissing,
    CoreError_Register_SecurityCodeMissing,
    CoreError_Register_PasswordMissing,
    CoreError_Register_ChecksumMissing,
    CoreError_Register_ActivateFailed,
    CoreError_Register_AlreadyExisted,
    
    CoreError_PasswordChange_OldPasswordMissing,
    CoreError_PasswordChange_NewPasswordMissing,
    CoreError_PasswordChange_NewPasswordTooShort,
    CoreError_PasswordChange_OldPasswordIncorrect,
    CoreError_PasswordChange_EmailMissing,
    CoreError_PasswordChange_NotFound,
    CoreError_PasswordChange_Failed,
    
    CoreError_PasswordRenew_EmailMissing,
    CoreError_PasswordRenew_SendFailed,
    CoreError_PasswordRenew_NotEnoughTime,
    CoreError_PasswordRenew_Failed,
    
    CoreError_AcceptTOS_EmailMissing,
    CoreError_AcceptTOS_TOSMissing,
    CoreError_AcceptTOS_TOSInvalid,
    CoreError_AcceptTOS_TOSDateOld,
    CoreError_AcceptTOS_NotFound,
    CoreError_AcceptTOS_Failed,
    
} CoreErrorCode;

@interface CoreError : NSError
+ (instancetype)errorWithCode:(CoreErrorCode)code;
+ (instancetype)errorWithCode:(CoreErrorCode)code message:(NSString *)message;
+ (instancetype)errorWithCode:(CoreErrorCode)code message:(NSString *)message reason:(NSString *)reason;
@end
