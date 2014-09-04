//
//  AccountAPI.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-17.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Core.h"
#import "AccountAPI.h"
#import "AccountNetwork.h"

#import "AFNetworkReachabilityManager.h"

@implementation AccountAPI

+ (NSOperation *)authorize:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(apiurl.absoluteString.length > 0);
    NSParameterAssert(username.length >= 5 && password.length >= 6);
    
    NSString *client_name = UIDevice.currentDevice.name;
    if (0 == client_name.length) {
        client_name = @"iOS";
    }
    
    NSDictionary *parameters =
    @{  @"email"        :username,
        @"password"     :password,
        @"client_name"  :client_name,
        @"client_id"    :@"7C4B5AC96435EFA0",
        @"client_secret":@"12d950b3c8d447f2ca6c83960fdf371d",
        @"grant_type"   :@"password"};
    
    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_Authorize authorization:@"" parameters:parameters completion:completion];
    
    return operation;
}

+ (NSOperation *)revoke:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    
    NSParameterAssert(apiurl.absoluteString.length > 0);
    NSParameterAssert(authorization.length > 0);
    
    if (0 == authorization.length) {
        NSParameterAssert(apiurl);
        completion(nil, nil); // already revoked.
        return nil;
    }
    
    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_Revoke authorization:authorization parameters:nil completion:completion];
    
    return operation;
}

+ (NSOperation *)passwordchange:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email passwordold:(NSString *)passwordold passwordnew:(NSString *)passwordnew completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSParameterAssert(email && passwordold && passwordnew);
    if (nil == email) email = @"";
    if (nil == passwordold) passwordold = @"";
    if (nil == passwordnew) passwordnew = @"";
    
    NSDictionary *parameters = @{ @"email":email, @"passwordold":passwordold, @"passwordnew":passwordnew };
    
    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_PasswordChange authorization:authorization parameters:parameters completion:completion];
    
    return operation;
}

+ (NSOperation *)passwordrenew:(NSURL *)apiurl email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    
    NSParameterAssert(email);
    if (nil == email) email = @"";
    
    NSDictionary *parameters = @{ @"email":email };
    
    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_PasswordRenew authorization:@"" parameters:parameters completion:completion];
    
    return operation;
}

+ (NSOperation *)getuser:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSDictionary *parameters = nil;

    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_GetUserInfo authorization:authorization parameters:parameters completion:completion];
    
    return operation;
}

+ (NSOperation *)accepttos:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSParameterAssert(email);
    if (email == nil) email = @"";
    
    NSString *date = [self RFC3339DateTimeStringForDate:[NSDate date]];
    NSParameterAssert(date.length > 0);
    NSDictionary *parameters = @{ @"email":email, @"tos":date };
    
    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_AcceptTOS authorization:authorization parameters:parameters completion:completion];
    
    return operation;
}

+ (NSOperation *)pogopluglogin:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSDictionary *parameters = nil;
    
    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_PogoplugLogin authorization:authorization parameters:parameters completion:completion];
    
    return operation;
}

+ (NSOperation *)storageauth:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSDictionary *parameters = nil;
    
    NSOperation *operation = [AccountNetwork post:apiurl path:AccountPath_StorageAuth authorization:authorization parameters:parameters completion:completion];
    
    return operation;
}

+ (NSString *)RFC3339DateTimeStringForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    
    //[rfc3339DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZZ"];
    //[rfc3339DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];  //formatter without milisecond
    [rfc3339DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];  //formatter without milisecond,with GMT
    //[rfc3339DateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    //convert date to RFC3339 string
    NSString *strDate = [rfc3339DateFormatter stringFromDate:date];
    
    //for ios 5.0 or former version, the string is "2012-05-23T12:03:25.089+GMT08:00"
    //for ios 6.0, the string is "2012-05-23T12:03:25.089+08:00",
    //so remove "GMT" string whatever.
    NSString* convertedStr = [strDate stringByReplacingOccurrencesOfString:@"GMT" withString:@"+00:00"];
    return convertedStr;
}

@end
