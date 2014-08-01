//
//  CoreError.h
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ErrorDomain           @"Core"
#define SubCodeErrorKey       @"SubCode"
#define DebugStringErrorKey   @"DebugString"
#define DebugPositionErrorKey @"DebugPosition"

typedef enum : int32_t {
    // unexpected error.
    // reason: may be caused by invalid response data, or data format changed but we don't known, or must not happend.
    // handle: for ui, can only say sorry to user;
    //         for core, log error with context, and it should be resolved later.
    Error_Unexpected,
    
    // unknown error.
    // reason: reasonalbe error, but we miss it currently.
    //         for frameworks, underlying error was got but not understand;
    //         for http status code, http status code was got but not understand;
    //         for server exception, code and message were got but not understand.
    // handle: for ui, show the message to user;
    //         for core, log error with context, and it should be resolved later.
    Error_Unknown,
    
    // network unavailable.
    // reason: wifi, wwan, lan,... not connected, proxy or route unavailable.
    // handle: for backup, will continue automatically when network resume to be available;
    //         for browsing, ui tell user to try again later manually.
    Error_NetworkUnavailable,
    
    // service unavailable.
    // reason: server maintenance.
    // handle: for both, ui tell user to try again later manually.
    Error_ServiceUnavailable,
    
    // account unauthorized.
    // reason: not login, or revoked by remote, or session expired.
    // handle: for both, ui should pop up a dialog to let user login with password.
    Error_Unauthorized,
    
    // request timeout.
    // reason: network speed is slow or network status is not stable.
    // handle: for backup, core should try again immediately;
    //         for browsing, ui tell user to try again later manually.
    Error_Timeout,
    
    // operation failed.
    // reason: multiple reasons, with subcode or underlying error.
    // handle: for backup, ui tell user to try again later manually;
    //         for browsing and setting, ui should alert user with the message.
    Error_Failed,
    
} ErrorCode;

typedef enum : int32_t {
    Error_None = 0, // no sub code.
    
    Error_Account_Login_DataMissing,
    Error_Account_Login_NicknameMissing,
    Error_Account_Login_PasswordMissing,
    Error_Account_Login_AccountInactived,
    Error_Account_Login_EmailPasswordMismatched,
    Error_Account_Login_TOSChanged,
    Error_Account_Login_NotFound,
    Error_Account_PasswordChange_OldPasswordMissing,
    Error_Account_PasswordChange_NewPasswordMissing,
    Error_Account_PasswordChange_NewPasswordTooShort,
    Error_Account_PasswordChange_OldPasswordIncorrect,
    Error_Account_PasswordChange_EmailMissing,
    Error_Account_PasswordChange_NotFound,
    Error_Account_PasswordChange_Failed,
    Error_Account_PasswordRenew_EmailMissing,
    Error_Account_PasswordRenew_SendFailed,
    Error_Account_PasswordRenew_NotEnoughTime,
    Error_Account_AcceptTOS_EmailMissing,
    Error_Account_AcceptTOS_TOSMissing,
    Error_Account_AcceptTOS_TOSInvalid,
    Error_Account_AcceptTOS_TOSDateOld,
    Error_Account_AcceptTOS_NotFound,
    
    Error_Pogoplug_ClientError       = 400,
    Error_Pogoplug_ServerError       = 500,
    Error_Pogoplug_InvalidArgument   = 600,
    Error_Pogoplug_OutOfRange        = 601,
    Error_Pogoplug_NotImplemented    = 602,
    Error_Pogoplug_NotAuthorized     = 606,
    Error_Pogoplug_Timeout           = 607,
    Error_Pogoplug_TemporaryFailure  = 608,
    Error_Pogoplug_NoSuchUser        = 800,
    Error_Pogoplug_NoSuchDevice      = 801,
    Error_Pogoplug_NoSuchService     = 802,
    Error_Pogoplug_NoSuchFile        = 804,
    Error_Pogoplug_InsufficientPermissions = 805,
    Error_Pogoplug_NotAvailable      = 806,
    Error_Pogoplug_StorageOffline    = 807,
    Error_Pogoplug_FileExists        = 808,
    Error_Pogoplug_NoSuchFileName    = 809,
    Error_Pogoplug_UserExists        = 810,
    Error_Pogoplug_UserNotValidated  = 811,
    Error_Pogoplug_NameTooLong       = 812,
    Error_Pogoplug_PasswordNotSet    = 813,
    Error_Pogoplug_ServiceExpired    = 815,
    Error_Pogoplug_InsufficientSpace = 817,
    Error_Pogoplug_Unsupported       = 818,
    Error_Pogoplug_ProvisionFailure  = 819,
    Error_Pogoplug_NotProvisioned    = 820,
    Error_Pogoplug_InvalidName       = 822,
    Error_Pogoplug_LimitReached      = 825,
    Error_Pogoplug_InvalidToken      = 826,
    Error_Pogoplug_TrialNotAllowed   = 831,
    Error_Pogoplug_CopyrightDenied   = 832,
} ErrorSubCode;

@interface Error : NSError
- (ErrorCode)code;
- (ErrorSubCode)subCode;
- (NSString *)localizedDescription;
- (NSString *)localizedDescriptionWithComment:(NSString *)comment;
+ (Error *)errorWithCode:(ErrorCode)code subCode:(ErrorSubCode)subCode underlyingError:(NSError *)underlyingError debugString:(NSString *)debugString file:(char *)file line:(int)line;
+ (Error *)tryGetErrorWithAccountResponse:(NSHTTPURLResponse *)response JSONObject:(NSDictionary *)json requestPath:(NSString *)path;
@end
