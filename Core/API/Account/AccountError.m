#import "AccountError.h"

@implementation AccountError

+ (NSString *)descriptionForCode:(AccountErrorCode)code
{
    switch (code) {
        case AccountError_NetworkNotAvailable:
            return NSLocalizedString(@"Network not available. Please turn on Wi-Fi or enable your mobile data connection.", @"error description") ;
        case AccountError_ServiceUnavailable:
            return NSLocalizedString(@"The service is temporarily unavailable due to maintenance.", @"error description");
            
        case AccountError_Login_DataMissing: // data:1
            return NSLocalizedString(@"The request data is missing.", @"error description");
        case AccountError_Login_NicknameMissing: // login:1
            return NSLocalizedString(@"Nickname is required but not given.", @"error description");
        case AccountError_Login_PasswordMissing: // login:2
            return NSLocalizedString(@"Password is required but not given.", @"error description");
        case AccountError_Login_AccountInactived: // login:3
            return NSLocalizedString(@"User account is not activated.", @"error description");
        case AccountError_Login_EmailPasswordMismatched: // login:4
            return NSLocalizedString(@"E-mail address and password do not match.", @"error description");
        case AccountError_Login_TOSChanged: // login:6
            return NSLocalizedString(@"Terms of use changed, need to agree to new terms of use.", @"error description");
        case AccountError_Login_NotFound: // login:7
            return NSLocalizedString(@"A user with the given email address wasn't found.", @"error description");
            
        case AccountError_Register_NicknameMissing: // register:1
            return NSLocalizedString(@"Nickname is required but not given.", @"error description");
        case AccountError_Register_EmailMissing: // register:3
            return NSLocalizedString(@"Email address is required but not given.", @"error description");
        case AccountError_Register_CountryMissing: // register:4
            return NSLocalizedString(@"Country is required but not given.", @"error description");
        case AccountError_Register_SecurityCodeMissing: // register:5
            return NSLocalizedString(@"Security code required but not given.", @"error description");
        case AccountError_Register_PasswordMissing: // register:6
            return NSLocalizedString(@"New password is required but not given.", @"error description");
        case AccountError_Register_ChecksumMissing: // register:7
            return NSLocalizedString(@"Checksum is required but not given.", @"error description");
        case AccountError_Register_ActivateFailed: // register 8
            return NSLocalizedString(@"Failed to activate account - most likely because the checksum was wrong.", @"error description");
        case AccountError_Register_AlreadyExisted: // invalid:email:String:1202
            return NSLocalizedString(@"A user with the given email already exists.", @"error description");
            
        case AccountError_PasswordChange_OldPasswordMissing: // password:1
            return NSLocalizedString(@"The current password is required but not given.", @"error description");
        case AccountError_PasswordChange_NewPasswordMissing: // password:2
            return NSLocalizedString(@"A new password is required but not given.", @"error description");
        case AccountError_PasswordChange_NewPasswordTooShort: // password:3
            return NSLocalizedString(@"The new password is too short. Password requires at least 6 characters.", @"error description");
        case AccountError_PasswordChange_OldPasswordIncorrect: // password:4
            return NSLocalizedString(@"The old password is incorrect.", @"error description");
        case AccountError_PasswordChange_EmailMissing: // invalid:email:String:1
            return NSLocalizedString(@"Missing required element \"email\".", @"error description");
        case AccountError_PasswordChange_NotFound: // user:passwordchange:1
            return NSLocalizedString(@"A user with the given email wasn't found.", @"error description");
        case AccountError_PasswordChange_Failed: // http statuc code 400
            return NSLocalizedString(@"Failed to change password.", @"error description");

        case AccountError_PasswordRenew_EmailMissing: // invalid:email:String:1
            return NSLocalizedString(@"Missing required element \"email\".", @"error description");
        case AccountError_PasswordRenew_SendFailed: // user:passwordrenew:1
            return NSLocalizedString(@"E-mail couldn't be send (e.g. no matching username or email address was found).", @"error description");
        case AccountError_PasswordRenew_NotEnoughTime: // user:passwordrenew:2
            return NSLocalizedString(@"Not enough time has elapsed since last \"Forgot Password\" request.", @"error description");
            
        case AccountError_AcceptTOS_EmailMissing: // 400 email:missing
            return NSLocalizedString(@"The email field is missing or empty.", @"error description");
        case AccountError_AcceptTOS_TOSMissing: // 400 tos:missing
            return NSLocalizedString(@"The tos field is missing or empty.", @"error description");
        case AccountError_AcceptTOS_TOSInvalid: // 400 ots:invalid
            return NSLocalizedString(@"The given tos value isn't a valid date.", @"error description");
        case AccountError_AcceptTOS_TOSDateOld: // 403
            return NSLocalizedString(@"The given tos date is older than the current TOS date", @"error description");
        case AccountError_AcceptTOS_NotFound: // 404
            return NSLocalizedString(@"A user with the given email wasn't found.", @"error description");
            
        case AccountError_Unknown:
             return NSLocalizedString(@"Unknown error.", @"error description");
        default:
            return @"";
    }
}


+ (NSError *)errorWithCode:(AccountErrorCode)code
{
    return [self errorWithCode:code message:nil reason:nil];
}

+ (NSError *)errorWithCode:(AccountErrorCode)code message:(NSString *)message
{
    return [self errorWithCode:code message:message reason:nil];
}

+ (NSError *)errorWithCode:(AccountErrorCode)code message:(NSString *)message reason:(NSString *)reason
{
    NSString *description = [self descriptionForCode:code];
    if (0 == description.length || (code == AccountError_Unknown && message.length > 0)) {
        description = message;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = description;
    if (reason.length > 0) {
        userInfo[NSLocalizedFailureReasonErrorKey] = reason;
    }
    
    return [self errorWithDomain:ErrorDomain_Account code:code userInfo:userInfo];
}

+ (NSError *)errorWithStatusCode:(NSInteger)statusCode
{
    // TODO
    return [self errorWithDomain:ErrorDomain_Account code:statusCode userInfo:nil];
}

@end
