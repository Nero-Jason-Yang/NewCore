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

+ (NSOperation *)signup:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password details:(NSDictionary *)details completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(username.length >= 5 && password.length >= 6);
    
    NSDictionary *parameters =
    @{  @"email"    :(username ? username : @""),
        @"password" :(password ? password : @"")};
    
    if (details.count > 0) {
        NSMutableDictionary *mdic = details.mutableCopy;
        [mdic addEntriesFromDictionary:parameters];
        parameters = mdic;
    }
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_REGISTER authorization:@"" parameters:parameters completion:completion];
}

+ (NSOperation *)authorize:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(username.length >= 5 && password.length >= 6);
    NSString *devicename = UIDevice.currentDevice.name;
    
    NSDictionary *parameters =
    @{  @"email"         :(username ? username : @""),
        @"password"      :(password ? password : @""),
        @"client_name"   :(devicename ? devicename : @"iOS"),
        @"client_id"     :@"7C4B5AC96435EFA0",
        @"client_secret" :@"12d950b3c8d447f2ca6c83960fdf371d",
        @"grant_type"    :@"password"};
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_AUTHORIZE authorization:@"" parameters:parameters completion:completion];
}

+ (NSOperation *)revoke:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    if (0 == authorization.length) {
        NSParameterAssert(apiurl);
        completion(nil, nil); // already revoked.
        return nil;
    }
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_REVOKE authorization:authorization parameters:nil completion:completion];
}

+ (NSOperation *)passwordchange:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email passwordold:(NSString *)passwordold passwordnew:(NSString *)passwordnew completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    NSParameterAssert(email && passwordold && passwordnew);
    
    NSDictionary *parameters =
    @{  @"email"       :(email ? email : @""),
        @"passwordold" :(passwordold ? passwordold : @""),
        @"passwordnew" :(passwordnew ? passwordnew : @"")};
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_PASSWORDCHANGE authorization:authorization parameters:parameters completion:completion];
}

+ (NSOperation *)passwordrenew:(NSURL *)apiurl email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(email);
    
    NSDictionary *parameters =
    @{  @"email" :(email ? email : @"")};
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_PASSWORDRENEW authorization:@"" parameters:parameters completion:completion];
}

+ (NSOperation *)getuser:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_GETUSER authorization:authorization parameters:nil completion:completion];
}

+ (NSOperation *)accepttos:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    NSString *date = [self RFC3339DateTimeStringForDate:[NSDate date]];
    
    NSDictionary *parameters =
    @{  @"email" :(email ? email : @""),
        @"tos"   :date};
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_ACCEPTTOS authorization:authorization parameters:parameters completion:completion];
}

+ (NSOperation *)pogopluglogin:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_POGOPLUGLOGIN authorization:authorization parameters:nil completion:completion];
}

+ (NSOperation *)storageauth:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    return [AccountNetwork post:apiurl path:ACCOUNT_APIPATH_STORAGEAUTH authorization:authorization parameters:nil completion:completion];
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
