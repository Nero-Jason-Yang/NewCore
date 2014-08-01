//
//  CoreError.m
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Error.h"
#import "AccountAPI.h"

@implementation Error

- (ErrorCode)code
{
    return [super code];
}

- (ErrorSubCode)subCode
{
    NSNumber *value = [self userInfo][SubCodeErrorKey];
    if ([value isKindOfClass:NSNumber.class]) {
        return value.integerValue;
    }
    return Error_None;
}

- (NSError *)underlyingError
{
    NSError *value = [self userInfo][NSUnderlyingErrorKey];
    if ([value isKindOfClass:NSError.class]) {
        return value;
    }
    return nil;
}

- (NSString *)localizedDescription
{
    NSString *description = [super localizedDescription];
    if (description) {
        return description;
    }
    
    description = [self localizedFailureReason];
    NSString *suggestion = [self localizedRecoverySuggestion];
    if (0 == description.length) {
        description = suggestion;
    } else if (suggestion.length > 0) {
        description = [description stringByAppendingFormat:@" %@", suggestion];
    }
    
    return nil;
}

- (NSString *)localizedDescriptionWithComment:(NSString *)comment
{
    NSString *description = [self localizedDescription];
    
    // TODO
    // to custom description based on comment (e.g. for UI special action).
    
    return description;
}

- (NSString *)localizedFailureReason
{
    NSString *reason = [super localizedFailureReason];
    if (reason) {
        return reason;
    }
    
    reason = [Error localizedFailureReasonForCode:self.code];
    
    if (self.code == Error_Failed) {
        NSString *subReason = [Error localizedFailureReasonForSubCode:self.subCode];
        if (subReason) {
            reason = subReason;
        }
    }
    
    if (!reason) {
        reason = [self underlyingError].localizedFailureReason;
    }
    
    return reason;
}

- (NSString *)localizedRecoverySuggestion
{
    NSString *suggestion = [super localizedRecoverySuggestion];
    if (suggestion) {
        return suggestion;
    }
    
    suggestion = [Error localizedRecoverySuggestionForCode:self.code];
    
    if (!suggestion) {
        suggestion = [self underlyingError].localizedRecoverySuggestion;
    }
    
    return suggestion;
}

+ (Error *)errorWithCode:(ErrorCode)code subCode:(ErrorSubCode)subCode underlyingError:(NSError *)underlyingError debugString:(NSString *)debugString file:(char *)file line:(int)line
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (subCode != Error_None) {
        userInfo[SubCodeErrorKey] = [NSNumber numberWithInteger:subCode];
    }
    if (underlyingError) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }
    if (debugString) {
        userInfo[DebugStringErrorKey] = debugString;
    }
    if (file) {
        userInfo[DebugPositionErrorKey] = [NSString stringWithFormat:@"file:%s line:%d", file, line];
    }
    if (0 == userInfo.count) {
        userInfo = nil;
    }
    return [[Error alloc] initWithDomain:ErrorDomain code:code userInfo:userInfo];
}

+ (NSString *)localizedRecoverySuggestionForCode:(ErrorCode)code
{
    switch (code) {
        case Error_Unexpected:
        case Error_Unknown:
            return NSLocalizedString(@"Please upgrade to the newest version if any.", @"ErrorSuggestion");
            
        case Error_NetworkUnavailable:
            return NSLocalizedString(@"Please turn on Wi-Fi or enable your mobile data connection.", @"ErrorSuggestion") ;
            
        case Error_Timeout:
        case Error_ServiceUnavailable:
            return NSLocalizedString(@"Please try again later.", @"ErrorSuggestion");
            
        case Error_Unauthorized:
            return NSLocalizedString(@"Please login your account.", @"ErrorSuggestion");
            
        case Error_Failed:
        default:
            return nil;
    }
}

+ (NSString *)localizedFailureReasonForCode:(ErrorCode)code
{
    switch (code) {
        case Error_Unexpected:
            return NSLocalizedString(@"Unexpected Error.", @"ErrorReason") ;
            
        case Error_Unknown:
            return NSLocalizedString(@"Unknown Error.", @"ErrorReason") ;
            
        case Error_NetworkUnavailable:
            return NSLocalizedString(@"Network not available.", @"ErrorReason") ;
            
        case Error_ServiceUnavailable:
            return NSLocalizedString(@"The service is temporarily unavailable due to maintenance.", @"ErrorReason");
            
        case Error_Unauthorized:
            return NSLocalizedString(@"You are not login or session expired.", @"ErrorReason");
            
        case Error_Timeout:
            return NSLocalizedString(@"Request timeout.", @"ErrorReason");
            
        case Error_Failed:
            return NSLocalizedString(@"Operation failed.", @"ErrorReason");
            
        default:
            return nil;
    }
}

+ (NSString *)localizedFailureReasonForSubCode:(ErrorSubCode)subCode
{
    switch (subCode) {
        case Error_Account_Login_DataMissing: // data:1
            return NSLocalizedString(@"The request data is missing.", @"AccountErrorReason");
        case Error_Account_Login_NicknameMissing: // login:1
            return NSLocalizedString(@"Nickname is required but not given.", @"AccountErrorReason");
        case Error_Account_Login_PasswordMissing: // login:2
            return NSLocalizedString(@"Password is required but not given.", @"AccountErrorReason");
        case Error_Account_Login_AccountInactived: // login:3
            return NSLocalizedString(@"Account is not activated.", @"AccountErrorReason");
        case Error_Account_Login_EmailPasswordMismatched: // login:4
            return NSLocalizedString(@"Email and password do not match.", @"AccountErrorReason");
        case Error_Account_Login_TOSChanged: // login:6
            return NSLocalizedString(@"Terms of use changed, need to agree to new terms of use.", @"AccountErrorReason");
        case Error_Account_Login_NotFound: // login:7
            return NSLocalizedString(@"Account with the given email wasn't found.", @"AccountErrorReason");
            
        case Error_Account_PasswordChange_OldPasswordMissing: // password:1
            return NSLocalizedString(@"Old password is required but not given.", @"AccountErrorReason");
        case Error_Account_PasswordChange_NewPasswordMissing: // password:2
            return NSLocalizedString(@"New password is required but not given.", @"AccountErrorReason");
        case Error_Account_PasswordChange_NewPasswordTooShort: // password:3
            return NSLocalizedString(@"New password is too short. Password requires at least 6 characters.", @"AccountErrorReason");
        case Error_Account_PasswordChange_OldPasswordIncorrect: // password:4
            return NSLocalizedString(@"Old password is incorrect.", @"AccountErrorReason");
        case Error_Account_PasswordChange_EmailMissing: // invalid:email:String:1
            return NSLocalizedString(@"Email is required but not given.", @"AccountErrorReason");
        case Error_Account_PasswordChange_NotFound: // user:passwordchange:1
            return NSLocalizedString(@"Account with the given email wasn't found.", @"AccountErrorReason");
        case Error_Account_PasswordChange_Failed: // http statuc code 400
            return NSLocalizedString(@"Failed to change password.", @"AccountErrorReason");
            
        case Error_Account_PasswordRenew_EmailMissing: // invalid:email:String:1
            return NSLocalizedString(@"Email is required but not given.", @"AccountErrorReason");
        case Error_Account_PasswordRenew_SendFailed: // user:passwordrenew:1
            return NSLocalizedString(@"Email couldn't be send (e.g. no matching username or email address was found).", @"AccountErrorReason");
        case Error_Account_PasswordRenew_NotEnoughTime: // user:passwordrenew:2
            return NSLocalizedString(@"Not enough time has elapsed since last \"Forgot Password\" request.", @"AccountErrorReason");
            
        case Error_Account_AcceptTOS_EmailMissing: // 400 email:missing
            return NSLocalizedString(@"Email is required but not given.", @"AccountErrorReason");
        case Error_Account_AcceptTOS_TOSMissing: // 400 tos:missing
            return NSLocalizedString(@"The TOS field is missing or empty.", @"AccountErrorReason");
        case Error_Account_AcceptTOS_TOSInvalid: // 400 ots:invalid
            return NSLocalizedString(@"The given TOS value isn't a valid date.", @"AccountErrorReason");
        case Error_Account_AcceptTOS_TOSDateOld: // 403
            return NSLocalizedString(@"The given TOS date is older than the current TOS date", @"AccountErrorReason");
        case Error_Account_AcceptTOS_NotFound: // 404
            return NSLocalizedString(@"Account with the given email wasn't found.", @"AccountErrorReason");

        case Error_Pogoplug_ClientError:            // 400
        case Error_Pogoplug_ServerError:            // 500
        case Error_Pogoplug_InvalidArgument:        // 600
        case Error_Pogoplug_OutOfRange:             // 601
        case Error_Pogoplug_NotImplemented:         // 602
        case Error_Pogoplug_NotAuthorized:          // 606
        case Error_Pogoplug_Timeout:                // 607
        case Error_Pogoplug_TemporaryFailure:       // 608
        case Error_Pogoplug_NoSuchUser:             // 800
        case Error_Pogoplug_NoSuchDevice:           // 801
        case Error_Pogoplug_NoSuchService:          // 802
        case Error_Pogoplug_NoSuchFile:             // 804
        case Error_Pogoplug_InsufficientPermissions:// 805
        case Error_Pogoplug_NotAvailable:           // 806
        case Error_Pogoplug_StorageOffline:         // 807
        case Error_Pogoplug_FileExists:             // 808
        case Error_Pogoplug_NoSuchFileName:         // 809
        case Error_Pogoplug_UserExists:             // 810
        case Error_Pogoplug_UserNotValidated:       // 811
        case Error_Pogoplug_NameTooLong:            // 812
        case Error_Pogoplug_PasswordNotSet:         // 813
        case Error_Pogoplug_ServiceExpired:         // 815
        case Error_Pogoplug_InsufficientSpace:      // 817
        case Error_Pogoplug_Unsupported:            // 818
        case Error_Pogoplug_ProvisionFailure:       // 819
        case Error_Pogoplug_NotProvisioned:         // 820
        case Error_Pogoplug_InvalidName:            // 822
        case Error_Pogoplug_LimitReached:           // 825
        case Error_Pogoplug_InvalidToken:           // 826
        case Error_Pogoplug_TrialNotAllowed:        // 831
        case Error_Pogoplug_CopyrightDenied:        // 832

        default:
            return nil;
    }
}

#pragma mark account

+ (Error *)tryGetErrorWithAccountResponse:(NSHTTPURLResponse *)response JSONObject:(NSDictionary *)json requestPath:(NSString *)path
{
    NSString *(^makeDebugString)() = ^ NSString *() {
        return [NSString stringWithFormat:@"response json: %@", json];
    };
    
    NSError *error = [NSError errorWithResponse:response];
    
    if (error) {
        switch (error.code) {
            case HTTPErrorUnauthorized:       // 401
                return [Error errorWithCode:Error_Unauthorized subCode:Error_None underlyingError:error debugString:makeDebugString() file:__FILE__ line:__LINE__];
            case HTTPErrorServiceUnavailable: // 503
                return [Error errorWithCode:Error_ServiceUnavailable subCode:Error_None underlyingError:error debugString:makeDebugString() file:__FILE__ line:__LINE__];
            case HTTPErrorRequestTimeout:     // 408
            case HTTPErrorGatewayTimeout:     // 504
                return [Error errorWithCode:Error_Timeout subCode:Error_None underlyingError:error debugString:makeDebugString() file:__FILE__ line:__LINE__];
        }
    }
    
    ErrorSubCode subCode = Error_None;
    NSString *exception = nil, *message = nil;
    if ([self getAccountExceptionWithResponseJSON:json exception:&exception message:&message]) {
        subCode = [Error subCodeWithAccountException:exception message:message requestPath:path];
    }
    if (Error_None == subCode && error) {
        subCode = [Error subCodeWithAccountHTTPStatusCode:error.code requestPath:path];
    }
    if (Error_None != subCode) {
        return [Error errorWithCode:Error_Failed subCode:subCode underlyingError:error debugString:makeDebugString() file:__FILE__ line:__LINE__];
    }
    
    if (error) {
        return [Error errorWithCode:Error_Failed subCode:Error_None underlyingError:error debugString:makeDebugString() file:__FILE__ line:__LINE__];
    }
    
    if (![json isKindOfClass:NSDictionary.class] && ![path isEqualToString:AccountAPIPath_AuthNcsRevoke]) {
        return [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:error debugString:makeDebugString() file:__FILE__ line:__LINE__];
    }
    
    return nil;
}

+ (BOOL)getAccountExceptionWithResponseJSON:(NSDictionary *)json exception:(NSString **)exception message:(NSString **)message
{
    NSParameterAssert(exception && message);
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    
    NSDictionary *details = [json objectForKey:@"details"];
    if (![details isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    
    BOOL (^parseException)(NSDictionary *, NSString **, NSString **) = ^BOOL(NSDictionary *exception, NSString **e_code, NSString **e_message) {
        NSString *s_code = exception[@"code"];
        if ([s_code isKindOfClass:NSString.class]) {
            *e_code = s_code;
            *e_message = [exception[@"message"] description];
            return YES;
        }
        return NO;
    };
    
    NSArray *exception_details = [details objectForKey:@"exception_details"];
    if ([exception_details isKindOfClass:NSArray.class]) {
        for (NSDictionary *item in exception_details) {
            if ([item isKindOfClass:NSDictionary.class]) {
                if (parseException(item, exception, message)) {
                    YES;
                }
            }
        }
    }
    else if ([exception_details isKindOfClass:NSDictionary.class]) {
        if (parseException((id)exception_details, exception, message)) {
            return YES;
        }
    }
    
    return NO;
}

+ (ErrorSubCode)subCodeWithAccountException:(NSString *)exception message:(NSString *)message requestPath:(NSString *)path
{
    if ([path isEqualToString:AccountAPIPath_AuthNcsAuthorize]) {
        if ([exception isEqualToString:@"data:1"]) {
            return Error_Account_Login_DataMissing;
        }
        if ([exception isEqualToString:@"login:1"]) {
            return Error_Account_Login_NicknameMissing;
        }
        if ([exception isEqualToString:@"login:2"]) {
            return Error_Account_Login_PasswordMissing;
        }
        if ([exception isEqualToString:@"login:3"]) {
            return Error_Account_Login_AccountInactived;
        }
        if ([exception isEqualToString:@"login:4"]) {
            return Error_Account_Login_EmailPasswordMismatched;
        }
        if ([exception isEqualToString:@"login:6"]) {
            return Error_Account_Login_TOSChanged;
        }
        if ([exception isEqualToString:@"login:7"]) {
            return Error_Account_Login_NotFound;
        }
        return Error_None;
    }
    
    if ([path isEqualToString:AccountAPIPath_AuthNcsRevoke]) {
        return Error_None;
    }
    
    if ([path isEqualToString:AccountAPIPath_AuthNcsPasswordchange]) {
        if ([exception isEqualToString:@"password:1"]) {
            return Error_Account_PasswordChange_OldPasswordMissing;
        }
        if ([exception isEqualToString:@"password:2"]) {
            return Error_Account_PasswordChange_NewPasswordMissing;
        }
        if ([exception isEqualToString:@"password:3"]) {
            return Error_Account_PasswordChange_NewPasswordTooShort;
        }
        if ([exception isEqualToString:@"password:4"]) {
            return Error_Account_PasswordChange_OldPasswordIncorrect;
        }
        if ([exception isEqualToString:@"invalid:email:String:1"]) {
            return Error_Account_PasswordChange_EmailMissing;
        }
        if ([exception isEqualToString:@"user:passwordchange:1"]) {
            return Error_Account_PasswordChange_NotFound;
        }
        if ([exception isEqualToString:@"invalid:passwordnew:String:1"]) {
            return Error_Account_PasswordChange_NewPasswordMissing;
        }
        return Error_None;
    }
    
    if ([path isEqualToString:AccountAPIPath_AuthNcsPasswordrenew]) {
        if ([exception isEqualToString:@"invalid:email:String:1"]) {
            return Error_Account_PasswordRenew_EmailMissing;
        }
        if ([exception isEqualToString:@"user:passwordrenew:1"]) {
            return Error_Account_PasswordRenew_SendFailed;
        }
        if ([exception isEqualToString:@"user:passwordrenew:2"]) {
            return Error_Account_PasswordRenew_NotEnoughTime;
        }
        return Error_None;
    }
    
    if ([path isEqualToString:AccountAPIPath_UserAccepttos]) {
        if ([exception isEqualToString:@"email:missing"]) {
            return Error_Account_AcceptTOS_EmailMissing;
        }
        if ([exception isEqualToString:@"tos:missing"]) {
            return Error_Account_AcceptTOS_TOSMissing;
        }
        if ([exception isEqualToString:@"ots:invalid"]) {
            return Error_Account_AcceptTOS_TOSInvalid;
        }
        return Error_None;
    }
    
    return Error_None;
}

+ (ErrorSubCode)subCodeWithAccountHTTPStatusCode:(NSInteger)code requestPath:(NSString *)path
{
    if ([path isEqualToString:AccountAPIPath_UserAccepttos]) {
        switch (code) {
            case HTTPErrorForbidden: // 403
                return Error_Account_AcceptTOS_TOSDateOld;
            case HTTPErrorNotFound:  // 404
                return Error_Account_AcceptTOS_NotFound;
        }
    }
    return Error_None;
}

#pragma mark pogoplug


@end
