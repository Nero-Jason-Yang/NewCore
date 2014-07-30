//
//  CoreError.m
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Error.h"

#define DebugPositionErrorKey @"DebugPosition"
#define DebugStringErrorKey   @"DebugString"

@implementation Error

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
            // reason = <underlyingError.reason>
            //        | "Operation failed."
            
            NSString *reason = [[self underlyingError] localizedFailureReason];
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
            // suggestion = <underrlyingError.suggestion>
            //            | <super.suggestion>
            //            | nil
            
            NSString *suggestion = [[self underlyingError] localizedRecoverySuggestion];
            if (suggestion) {
                return suggestion;
            }
            
            // through
        }
            
        default:
            return [super localizedRecoverySuggestion];
    }
}

+ (Error *)errorWithCode:(ErrorCode)code underlyingError:(opt NSError *)underlyingError
{
    return [self errorWithCode:code underlyingError:underlyingError debugString:nil debugPosition:nil];
}

+ (Error *)errorWithCode:(ErrorCode)code underlyingError:(opt NSError *)underlyingError debugString:(opt NSString *)debugString file:(char *)file line:(int)line
{
    return [self errorWithCode:code underlyingError:underlyingError debugString:debugString debugPosition:[NSString stringWithFormat:@"File:%s Line:%d", file, line]];
}

+ (Error *)errorWithCode:(ErrorCode)code underlyingError:(opt NSError *)underlyingError debugString:(opt NSString *)debugString debugPosition:(opt NSString *)debugPosition
{
    if (code == Error_Failed) {
        NSAssert(underlyingError, @"For \"Failed\" error it must contains an underlying error as details.");
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (underlyingError) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }
    if (debugPosition) {
        userInfo[DebugPositionErrorKey] = debugPosition;
    }
    if (debugString) {
        userInfo[DebugStringErrorKey] = debugString;
    }
    if (userInfo.count == 0) {
        userInfo = nil;
    }
    return [[Error alloc] initWithDomain:ErrorDomain code:code userInfo:userInfo];
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
        case AccountError_Login_DataMissing: // data:1
            return NSLocalizedString(@"The request data is missing.", @"AccountErrorReason");
        case AccountError_Login_NicknameMissing: // login:1
            return NSLocalizedString(@"Nickname is required but not given.", @"AccountErrorReason");
        case AccountError_Login_PasswordMissing: // login:2
            return NSLocalizedString(@"Password is required but not given.", @"AccountErrorReason");
        case AccountError_Login_AccountInactived: // login:3
            return NSLocalizedString(@"Account is not activated.", @"AccountErrorReason");
        case AccountError_Login_EmailPasswordMismatched: // login:4
            return NSLocalizedString(@"Email and password do not match.", @"AccountErrorReason");
        case AccountError_Login_TOSChanged: // login:6
            return NSLocalizedString(@"Terms of use changed, need to agree to new terms of use.", @"AccountErrorReason");
        case AccountError_Login_NotFound: // login:7
            return NSLocalizedString(@"Account with the given email wasn't found.", @"AccountErrorReason");
            
        case AccountError_PasswordChange_OldPasswordMissing: // password:1
            return NSLocalizedString(@"Old password is required but not given.", @"AccountErrorReason");
        case AccountError_PasswordChange_NewPasswordMissing: // password:2
            return NSLocalizedString(@"New password is required but not given.", @"AccountErrorReason");
        case AccountError_PasswordChange_NewPasswordTooShort: // password:3
            return NSLocalizedString(@"New password is too short. Password requires at least 6 characters.", @"AccountErrorReason");
        case AccountError_PasswordChange_OldPasswordIncorrect: // password:4
            return NSLocalizedString(@"Old password is incorrect.", @"AccountErrorReason");
        case AccountError_PasswordChange_EmailMissing: // invalid:email:String:1
            return NSLocalizedString(@"Email is required but not given.", @"AccountErrorReason");
        case AccountError_PasswordChange_NotFound: // user:passwordchange:1
            return NSLocalizedString(@"Account with the given email wasn't found.", @"AccountErrorReason");
        case AccountError_PasswordChange_Failed: // http statuc code 400
            return NSLocalizedString(@"Failed to change password.", @"AccountErrorReason");
            
        case AccountError_PasswordRenew_EmailMissing: // invalid:email:String:1
            return NSLocalizedString(@"Email is required but not given.", @"AccountErrorReason");
        case AccountError_PasswordRenew_SendFailed: // user:passwordrenew:1
            return NSLocalizedString(@"Email couldn't be send (e.g. no matching username or email address was found).", @"AccountErrorReason");
        case AccountError_PasswordRenew_NotEnoughTime: // user:passwordrenew:2
            return NSLocalizedString(@"Not enough time has elapsed since last \"Forgot Password\" request.", @"AccountErrorReason");
            
        case AccountError_AcceptTOS_EmailMissing: // 400 email:missing
            return NSLocalizedString(@"Email is required but not given.", @"AccountErrorReason");
        case AccountError_AcceptTOS_TOSMissing: // 400 tos:missing
            return NSLocalizedString(@"The TOS field is missing or empty.", @"AccountErrorReason");
        case AccountError_AcceptTOS_TOSInvalid: // 400 ots:invalid
            return NSLocalizedString(@"The given TOS value isn't a valid date.", @"AccountErrorReason");
        case AccountError_AcceptTOS_TOSDateOld: // 403
            return NSLocalizedString(@"The given TOS date is older than the current TOS date", @"AccountErrorReason");
        case AccountError_AcceptTOS_NotFound: // 404
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

+ (AccountError *)errorWithCode:(AccountErrorCode)code underlyingError:(opt NSError *)underlyingError debugString:(opt NSString *)debugString file:(char *)file line:(int)line
{
    // TODO
    return nil;
}

+ (AccountError *)errorWithException:(NSString *)exception message:(NSString *)message underlyingError:(opt NSError *)underlyingError debugString:(opt NSString *)debugString file:(char *)file line:(int)line
{
    return [self errorWithException:exception message:message underlyingError:underlyingError debugString:debugString debugPosition:[NSString stringWithFormat:@"File:%s Line:%d", file, line]];
}

+ (AccountError *)errorWithException:(NSString *)exception message:(NSString *)message underlyingError:(opt NSError *)underlyingError debugString:(opt NSString *)debugString debugPosition:(opt NSString *)debugPosition
{
    NSInteger code = 0;
    // TODO
    // to convert exception and message into code.
    // ...
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (underlyingError) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }
    if (debugPosition) {
        userInfo[DebugPositionErrorKey] = debugPosition;
    }
    if (debugString) {
        userInfo[DebugStringErrorKey] = debugString;
    }
    if (userInfo.count == 0) {
        userInfo = nil;
    }
    return [[AccountError alloc] initWithDomain:AccountErrorDomain code:code userInfo:userInfo];
}

@end

@implementation PogoplugError
+ (instancetype)errorWithCode:(NSInteger)code reason:(opt NSString *)reason underlying:(opt NSError *)underlying position:(opt NSString *)position
{
    return nil;
}
@end

@implementation HttpError
+ (instancetype)errorWithCode:(NSInteger)code reason:(opt NSString *)reason position:(opt NSString *)position
{
    return nil;
}
@end
