//
//  CoreError.m
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Error.h"
#import "AccountAPI.h"

#define MethodErrorKey   @"Method"
#define CommentErrorKey  @"Comment"
#define PositionErrorKey @"Position"

@interface BaseError ()
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)underlyingError method:(NSString *)method comment:(NSString *)comment file:(char *)file line:(int)line;
- (NSError *)underlyingError;
@end

@implementation BaseError

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)underlyingError method:(NSString *)method comment:(NSString *)comment file:(char *)file line:(int)line
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (underlyingError) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }
    if (method) {
        userInfo[MethodErrorKey] = method;
    }
    if (comment) {
        userInfo[CommentErrorKey] = comment;
    }
    if (file) {
        userInfo[PositionErrorKey] = [NSString stringWithFormat:@"File:%s Line:%d", file, line];
    }
    if (userInfo.count == 0) {
        userInfo = nil;
    }
    return [super initWithDomain:domain code:code userInfo:userInfo];
}

- (NSError *)underlyingError
{
    return self.userInfo[NSUnderlyingErrorKey];
}

- (NSString *)localizedDescription
{
    // description = <super.description>
    //             | <reason> <suggestion>
    //             | <underlyingError.description>
    
    NSString *description = [super localizedDescription];
    
    if (!description) {
        description = self.localizedFailureReason;
        
        NSString *suggestion = self.localizedRecoverySuggestion;
        if (0 == description.length) {
            description = suggestion;
        } else if (suggestion.length > 0) {
            description = [description stringByAppendingFormat:@" %@", suggestion];
        }
    }
    
    if (!description) {
        description = self.underlyingError.localizedDescription;
    }
    
    return description;
}

@end


@implementation CoreError

- (NSString *)localizedFailureReason
{
    switch (self.code) {
        case Error_Unexpected:
            return NSLocalizedString(@"Unexpected Error.", @"CoreErrorReason") ;

        case Error_Unknown:
            return NSLocalizedString(@"Unknown Error.", @"CoreErrorReason") ;
            
        case Error_NetworkUnavailable:
            return NSLocalizedString(@"Network not available.", @"CoreErrorReason") ;
            
        case Error_ServiceUnavailable:
            return NSLocalizedString(@"The service is temporarily unavailable due to maintenance.", @"CoreErrorReason");
  
        case Error_Unauthorized:
            return NSLocalizedString(@"You are not login or session expired.", @"CoreErrorReason");
            
        case Error_Timeout:
            return NSLocalizedString(@"Request timeout.", @"CoreErrorReason");
            
        case Error_Failed: {
            // reason = <super.reason>
            //        | <underlyingError.reason>
            //        | "Operation failed."
            
            NSString *reason = [super localizedFailureReason];
            if (reason) {
                return reason;
            }
            reason = [[self underlyingError] localizedFailureReason];
            if (reason) {
                return reason;
            }
            return NSLocalizedString(@"Operation failed.", @"CoreErrorReason");
        }
            
        default:
            return [super localizedFailureReason];
    }
}

- (NSString *)localizedRecoverySuggestion
{
    switch (self.code) {
        case Error_Unexpected:
        case Error_Unknown:
            return NSLocalizedString(@"Please upgrade to the newest version if any.", @"CoreErrorSuggestion");
            
        case Error_NetworkUnavailable:
            return NSLocalizedString(@"Please turn on Wi-Fi or enable your mobile data connection.", @"CoreErrorSuggestion") ;
            
        case Error_Timeout:
        case Error_ServiceUnavailable:
            return NSLocalizedString(@"Please try again later.", @"CoreErrorSuggestion");
            
        case Error_Unauthorized:
            return NSLocalizedString(@"Please login your account.", @"CoreErrorSuggestion");
            
        case Error_Failed: {
            // suggestion = <super.suggestion>
            //            | <underrlyingError.suggestion>
            //            | nil
            
            NSString *suggestion = [super localizedRecoverySuggestion];
            if (suggestion) {
                return suggestion;
            }
            suggestion = [[self underlyingError] localizedRecoverySuggestion];
            if (suggestion) {
                return suggestion;
            }
            return nil;
        }
            
        default:
            return [super localizedRecoverySuggestion];
    }
}

+ (CoreError *)errorWithCode:(CoreErrorCode)code underlyingError:(NSError *)underlyingError method:(NSString *)method comment:(NSString *)comment file:(char *)file line:(int)line
{
    NSAssert((code != Error_Unexpected && code != Error_Unknown), ([NSString stringWithFormat:@"%@ %@", method, comment]));
    if (code == Error_Failed) {
        NSAssert(underlyingError, @"For \"Failed\" error it must contains an underlying error as details.");
    }
    
    return [[CoreError alloc] initWithDomain:CoreErrorDomain code:code underlyingError:underlyingError method:method comment:comment file:file line:line];
}

@end


@implementation AccountError

- (NSError *)underlyingError
{
    return self.userInfo[NSUnderlyingErrorKey];
}

- (NSString *)localizedDescription
{
    // description = <reason>+" "+<suggestion>
    //             | <reason>
    //             | <suggestion>
    //             | <super.description>
    //             | <underlyingError.description>
    
    NSString *description = self.localizedFailureReason;
    NSString *suggestion = self.localizedRecoverySuggestion;
    
    if (0 == description.length) {
        description = suggestion;
    } else if (suggestion.length > 0) {
        description = [description stringByAppendingFormat:@" %@", suggestion];
    }
    
    if (!description) {
        description = [super localizedDescription];
        if (!description) {
            description = [[self underlyingError] localizedDescription];
        }
    }
    
    return description;
}

- (NSString *)localizedFailureReason
{
    switch (self.code) {
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
            
        default:
            NSAssert(NO, @"Invalid AccountErrorCode was specified.");
            return [super localizedFailureReason];
    }
}

- (NSString *)localizedRecoverySuggestion
{
    switch (self.code) {
            // TODO
            // ...
            
        default:
            return [super localizedRecoverySuggestion];
    }
}

#pragma mark errors

- (NSError *)getErrorForPath:(NSString *)path statusCode:(NSInteger)statusCode exceptionCode:(NSString *)exceptionCode message:(NSString *)message
{
    NSError *error = nil;
    
    if ([path isEqualToString:AccountAPIPath_AuthNcsAuthorize]) {
        error = [self getErrorForLogin:nil statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_AuthNcsRevoke]) {
        error = [self getErrorForLogout:nil statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_AuthNcsPasswordchange]) {
        error = [self getErrorForPasswordchange:nil statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_AuthNcsPasswordrenew]) {
        error = [self getErrorForPasswordrenew:nil statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_UserAccepttos]) {
        error = [self getErrorForAccepttos:nil statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else {
        error = [self getUnknownErrorForPath:path data:nil statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    
    return error;
}

- (NSError *)getErrorForLogin:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"data:1"]) {
        return [AccountError errorWithCode:Error_Account_Login_DataMissing message:message];
    }
    if ([code isEqualToString:@"login:1"]) {
        return [AccountError errorWithCode:Error_Account_Login_NicknameMissing message:message];
    }
    if ([code isEqualToString:@"login:2"]) {
        return [AccountError errorWithCode:Error_Account_Login_PasswordMissing message:message];
    }
    if ([code isEqualToString:@"login:3"]) {
        return [AccountError errorWithCode:Error_Account_Login_AccountInactived message:message];
    }
    if ([code isEqualToString:@"login:4"]) {
        return [AccountError errorWithCode:Error_Account_Login_EmailPasswordMismatched message:message];
    }
    if ([code isEqualToString:@"login:6"]) {
        return [AccountError errorWithCode:Error_Account_Login_TOSChanged message:message];
    }
    if ([code isEqualToString:@"login:7"]) {
        return [AccountError errorWithCode:Error_Account_Login_NotFound message:message];
    }
    return nil;
}

- (NSError *)getErrorForLogout:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"register:1"]) {
        return [AccountError errorWithCode:Error_Account_Register_NicknameMissing message:message];
    }
    if ([code isEqualToString:@"register:3"]) {
        return [AccountError errorWithCode:Error_Account_Register_EmailMissing message:message];
    }
    if ([code isEqualToString:@"register:4"]) {
        return [AccountError errorWithCode:Error_Account_Register_CountryMissing message:message];
    }
    if ([code isEqualToString:@"register:5"]) {
        return [AccountError errorWithCode:Error_Account_Register_SecurityCodeMissing message:message];
    }
    if ([code isEqualToString:@"register:6"]) {
        return [AccountError errorWithCode:Error_Account_Register_PasswordMissing message:message];
    }
    if ([code isEqualToString:@"register:7"]) {
        return [AccountError errorWithCode:Error_Account_Register_ChecksumMissing message:message];
    }
    if ([code isEqualToString:@"register:8"]) {
        return [AccountError errorWithCode:Error_Account_Register_ActivateFailed message:message];
    }
    if ([code isEqualToString:@"invalid:email:String:1202"]) {
        return [AccountError errorWithCode:Error_Account_Register_AlreadyExisted message:message];
    }
    return nil;
}

- (NSError *)getErrorForPasswordchange:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"password:1"]) {
        return [AccountError errorWithCode:Error_Account_PasswordChange_OldPasswordMissing message:message];
    }
    if ([code isEqualToString:@"password:2"]) {
        return [AccountError errorWithCode:Error_Account_PasswordChange_NewPasswordMissing message:message];
    }
    if ([code isEqualToString:@"password:3"]) {
        return [AccountError errorWithCode:Error_Account_PasswordChange_NewPasswordTooShort message:message];
    }
    if ([code isEqualToString:@"password:4"]) {
        return [AccountError errorWithCode:Error_Account_PasswordChange_OldPasswordIncorrect message:message];
    }
    if ([code isEqualToString:@"invalid:email:String:1"]) {
        return [AccountError errorWithCode:Error_Account_PasswordChange_EmailMissing message:message];
    }
    if ([code isEqualToString:@"user:passwordchange:1"]) {
        return [AccountError errorWithCode:Error_Account_PasswordChange_NotFound message:message];
    }
    if ([code isEqualToString:@"invalid:passwordnew:String:1"]) {
        return [AccountError errorWithCode:Error_Account_PasswordChange_NewPasswordMissing message:message];
    }
    return nil;
}

- (NSError *)getErrorForPasswordrenew:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"invalid:email:String:1"]) {
        return [AccountError errorWithCode:Error_Account_PasswordRenew_EmailMissing message:message];
    }
    if ([code isEqualToString:@"user:passwordrenew:1"]) {
        return [AccountError errorWithCode:Error_Account_PasswordRenew_SendFailed message:message];
    }
    if ([code isEqualToString:@"user:passwordrenew:2"]) {
        return [AccountError errorWithCode:Error_Account_PasswordRenew_NotEnoughTime message:message];
    }
    return nil;
}

- (NSError *)getErrorForAccepttos:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"email:missing"]) {
        return [AccountError errorWithCode:Error_Account_AcceptTOS_EmailMissing message:message];
    }
    if ([code isEqualToString:@"tos:missing"]) {
        return [AccountError errorWithCode:Error_Account_AcceptTOS_TOSMissing message:message];
    }
    if ([code isEqualToString:@"ots:invalid"]) {
        return [AccountError errorWithCode:Error_Account_AcceptTOS_TOSInvalid message:message];
    }
    if (statusCode == 403) {
        return [AccountError errorWithCode:Error_Account_AcceptTOS_TOSDateOld message:nil];
    }
    if (statusCode == 404) {
        return [AccountError errorWithCode:Error_Account_AcceptTOS_NotFound message:nil];
    }
    return nil;
}

- (NSError *)getUnknownErrorForPath:(NSString *)requestPath data:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if (code.length > 0) {
        NSString *reason = [NSString stringWithFormat:@"Nero Account Error with HTTP status-code:%d, exception-code:%@, message:%@", (int)statusCode, code, message];
        
        //[[GAI sharedInstance].defaultTracker send:[GAIDictionaryBuilder createExceptionWithDescription:str withFatal:@NO].build];
        
        return [AccountError errorWithCode:Error_Account_Unknown message:message reason:reason];
    }
    
    if (statusCode >= 400) {
        return [AccountError errorWithStatusCode:statusCode];
    }
    
    return nil;
}

+ (AccountErrorCode)codeWithException:(NSString *)exception message:(NSString *)message response:(NSHTTPURLResponse *)response method:(NSString *)method
{
    // TODO
    
    return 0;
}

+ (AccountError *)errorWithCode:(AccountErrorCode)code response:(NSHTTPURLResponse *)response method:(NSString *)method comment:(NSString *)comment file:(char *)file line:(int)line
{
    HttpError *underlyingError = [HttpError errorWithResponse:response];
    return [[AccountError alloc] initWithDomain:AccountErrorDomain code:code underlyingError:underlyingError method:method comment:comment file:file line:line];
}

+ (BaseError *)errorWithException:(NSString *)exception message:(NSString *)message response:(NSHTTPURLResponse *)response method:(NSString *)method comment:(NSString *)comment file:(char *)file line:(int)line
{
    HttpError *underlyingError = [HttpError errorWithResponse:response];
    if (underlyingError) {
        switch (underlyingError.code) {
            case 401:
                return [CoreError errorWithCode:Error_Unauthorized underlyingError:underlyingError method:method comment:comment file:file line:line];
            case 503:
                return [CoreError errorWithCode:Error_ServiceUnavailable underlyingError:underlyingError method:method comment:comment file:file line:line];
        }
    }
    
    AccountErrorCode code = [self codeWithException:exception message:message response:response method:method];
    
    if (0 == code) {
        if (message.length > 0) {
            return [[CoreError alloc] initWithDomain:CoreErrorDomain code:Error_Unknown underlyingError:underlyingError method:method comment:comment file:file line:line];
        } else {
            return [[CoreError alloc] initWithDomain:CoreErrorDomain code:Error_Unexpected underlyingError:underlyingError method:method comment:comment file:file line:line];
        }
    }
    
    return [[AccountError alloc] initWithDomain:AccountErrorDomain code:code underlyingError:underlyingError method:method comment:comment file:file line:line];
}

@end


@implementation PogoplugError

+ (PogoplugErrorCode)codeWithException:(NSString *)exception message:(NSString *)message response:(NSHTTPURLResponse *)response method:(NSString *)method
{
    // TODO
    
    return 0;
}

+ (PogoplugError *)errorWithCode:(PogoplugErrorCode)code response:(NSHTTPURLResponse *)response method:(NSString *)method comment:(NSString *)comment file:(char *)file line:(int)line
{
    HttpError *underlyingError = [HttpError errorWithResponse:response];
    return [[PogoplugError alloc] initWithDomain:PogoplugErrorDomain code:code underlyingError:underlyingError method:method comment:comment file:file line:line];
}

+ (BaseError *)errorWithException:(NSString *)exception message:(NSString *)message response:(NSHTTPURLResponse *)response method:(NSString *)method comment:(NSString *)comment file:(char *)file line:(int)line
{
    HttpError *underlyingError = [HttpError errorWithResponse:response];
    PogoplugErrorCode code = [self codeWithException:exception message:message response:response method:method];
    
    if (0 == code) {
        if (message.length > 0) {
            return [[CoreError alloc] initWithDomain:CoreErrorDomain code:Error_Unknown underlyingError:underlyingError method:method comment:comment file:file line:line];
        } else {
            return [[CoreError alloc] initWithDomain:CoreErrorDomain code:Error_Unexpected underlyingError:underlyingError method:method comment:comment file:file line:line];
        }
    }
    
    return [[PogoplugError alloc] initWithDomain:PogoplugErrorDomain code:code underlyingError:underlyingError method:method comment:comment file:file line:line];
}

@end


@implementation HttpError

+ (HttpError *) errorWithResponse:(NSHTTPURLResponse *)response
{
    if (![response isKindOfClass:NSHTTPURLResponse.class]) {
        return nil;
    }
    if (response.statusCode < 400) {
        return nil;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSURLErrorKey] = response.URL;
    userInfo[CommentErrorKey] = response.allHeaderFields;
    userInfo[NSLocalizedFailureReasonErrorKey] = [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode];
    return [[HttpError alloc] initWithDomain:HttpErrorDomain code:response.statusCode userInfo:userInfo];
}

@end
