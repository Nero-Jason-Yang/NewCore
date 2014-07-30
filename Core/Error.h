//
//  CoreError.h
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Error;
@class AccountError;
@class PogoplugError;
@class HttpError;

#define ErrorDomain         @"Core"
#define AccountErrorDomain  @"Account"
#define PogoplugErrorDomain @"Pogoplug"
#define HttpErrorDomain     @"Http"

typedef enum : int32_t {
    // unexpected error, can not handle currently.
    // reason: may be caused by invalid response data, or data format changed but we don't known, or should not happend.
    // handle: for ui, can only say sorry to user;
    //       : for core, log error with context, and it should be resolved later.
    Error_Unexpected,
    
    // unknown error.
    // reason: for frameworks, underlying error was got but not understand;
    //       : for http status code, http status code was got but not understand;
    //       : for server exception, code and message were got but not understand.
    // handle: for ui, show the message to user;
    //       : for core, log error with context, and it should be resolved later.
    Error_Unknown,
    
    // network unavailable.
    // reason: wifi, wwan, lan,... not connected, proxy or route unavailable.
    // handle: for backup, will continue automatically when network resume to be available;
    //       : for browsing, ui tell user to try again later manually.
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
    //       : for browsing, ui tell user to try again later manually.
    Error_Timeout,
    
    // operation failed.
    // reason: multiple, with friendly message.
    // handle: for backup, ui tell user to try again later manually;
    //       : for browsing and setting, ui should alert user with the message.
    Error_Failed,
    
} ErrorCode;


typedef enum : int32_t {
    AccountError_Unknown = 0,
    AccountError_HostUnspecified,
    AccountError_NetworkNotAvailable,
    AccountError_ServiceUnavailable,
    AccountError_Unauthorized,
    AccountError_InvalidResponseData, // unexpected, the response data is invalid.
    
    AccountError_Login_DataMissing,
    AccountError_Login_NicknameMissing,
    AccountError_Login_PasswordMissing,
    AccountError_Login_AccountInactived,
    AccountError_Login_EmailPasswordMismatched,
    AccountError_Login_TOSChanged,
    AccountError_Login_NotFound,
    
    AccountError_Register_NicknameMissing,
    AccountError_Register_EmailMissing,
    AccountError_Register_CountryMissing,
    AccountError_Register_SecurityCodeMissing,
    AccountError_Register_PasswordMissing,
    AccountError_Register_ChecksumMissing,
    AccountError_Register_ActivateFailed,
    AccountError_Register_AlreadyExisted,
    
    AccountError_PasswordChange_OldPasswordMissing,
    AccountError_PasswordChange_NewPasswordMissing,
    AccountError_PasswordChange_NewPasswordTooShort,
    AccountError_PasswordChange_OldPasswordIncorrect,
    AccountError_PasswordChange_EmailMissing,
    AccountError_PasswordChange_NotFound,
    AccountError_PasswordChange_Failed,
    
    AccountError_PasswordRenew_EmailMissing,
    AccountError_PasswordRenew_SendFailed,
    AccountError_PasswordRenew_NotEnoughTime,
    AccountError_PasswordRenew_Failed,
    
    AccountError_AcceptTOS_EmailMissing,
    AccountError_AcceptTOS_TOSMissing,
    AccountError_AcceptTOS_TOSInvalid,
    AccountError_AcceptTOS_TOSDateOld,
    AccountError_AcceptTOS_NotFound,
    AccountError_AcceptTOS_Failed,
    
} AccountErrorCode;

typedef enum : int32_t {
    PogoplugError_ClientError       = 400,
    PogoplugError_ServerError       = 500,
    PogoplugError_InvalidArgument   = 600,
    PogoplugError_OutOfRange        = 601,
    PogoplugError_NotImplemented    = 602,
    PogoplugError_NotAuthorized     = 606,
    PogoplugError_Timeout           = 607,
    PogoplugError_TemporaryFailure  = 608,
    PogoplugError_NoSuchUser        = 800,
    PogoplugError_NoSuchDevice      = 801,
    PogoplugError_NoSuchService     = 802,
    PogoplugError_NoSuchFile        = 804,
    PogoplugError_InsufficientPermissions = 805,
    PogoplugError_NotAvailable      = 806,
    PogoplugError_StorageOffline    = 807,
    PogoplugError_FileExists        = 808,
    PogoplugError_NoSuchFileName    = 809,
    PogoplugError_UserExists        = 810,
    PogoplugError_UserNotValidated  = 811,
    PogoplugError_NameTooLong       = 812,
    PogoplugError_PasswordNotSet    = 813,
    PogoplugError_ServiceExpired    = 815,
    PogoplugError_InsufficientSpace = 817,
    PogoplugError_Unsupported       = 818,
    PogoplugError_ProvisionFailure  = 819,
    PogoplugError_NotProvisioned    = 820,
    PogoplugError_InvalidName       = 822,
    PogoplugError_LimitReached      = 825,
    PogoplugError_InvalidToken      = 826,
    PogoplugError_TrialNotAllowed   = 831,
    PogoplugError_CopyrightDenied   = 832,
    PogoplugError_NotFound,
} PogoplugErrorCode;

typedef enum : int32_t {
    HttpError_BadRequest            = 400,
    HttpError_Unauthorized          = 401,
    HttpError_PaymentRequired       = 402,
    HttpError_Forbidden             = 403,
    HttpError_NotFound              = 404,
    HttpError_MethodNotAllowed      = 405,
    HttpError_NotAcceptable         = 406,
    HttpError_RequestTimeout        = 408,
    HttpError_Conflict              = 409,
    HttpError_Gone                  = 410,
    HttpError_LengthRequired        = 411,
    HttpError_PreconditionFailed    = 412,
    HttpError_RequestURITooLong     = 414,
    HttpError_ExpectationFailed     = 417,
    HttpError_TooManyConnections    = 421,
    HttpError_UnprocessableEntity   = 422,
    HttpError_Locked                = 423,
    HttpError_FailedDependency      = 424,
    HttpError_UnorderedCollection   = 425,
    HttpError_UpgradeRequired       = 426,
    HttpError_RetryWith             = 449,
    HttpError_InternalServerError   = 500,
    HttpError_NotImplemented        = 501,
    HttpError_BadGateway            = 502,
    HttpError_ServiceUnavailable    = 503,
    HttpError_GatewayTimeout        = 504,
    HttpError_InsufficientStorage   = 507,
    HttpError_LoopDetected          = 508,
    HttpError_NotExtended           = 510,
} HttpErrorCode;

@interface Error : NSError
+ (Error *)errorWithCode:(ErrorCode)code underlyingError:(opt NSError *)underlyingError debugString:(opt NSString *)debugString file:(char *)file line:(int)line;
@end

@interface AccountError : NSError
+ (instancetype)errorWithCode:(NSString *)code message:(NSString *)message reason:(opt NSString *)reason underlying:(opt NSError *)underlying position:(opt NSString *)position;
+ (NSError *)errorWithCode:(AccountErrorCode)code;
+ (NSError *)errorWithCode:(AccountErrorCode)code message:(NSString *)message;
+ (NSError *)errorWithCode:(AccountErrorCode)code message:(NSString *)message reason:(NSString *)reason;
+ (NSError *)errorWithStatusCode:(NSInteger)statusCode;
@end

@interface PogoplugError : NSError
+ (instancetype)errorWithCode:(NSInteger)code reason:(opt NSString *)reason underlying:(opt NSError *)underlying position:(opt NSString *)position;
+ (NSError *)errorWithCode:(PogoplugErrorCode)code;
@end

@interface HttpError : NSError
+ (instancetype)errorWithCode:(NSInteger)code reason:(opt NSString *)reason position:(opt NSString *)position;
@end
