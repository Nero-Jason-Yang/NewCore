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

+ (void)authorize:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password completion:(void(^)(NSString *authorization, NSError *error))completion
{
    NSParameterAssert(completion);
    
    NSParameterAssert(username.length >= 5 && password.length >= 6);
    
    NSString *client_name = UIDevice.currentDevice.name;
    if (0 == client_name.length) {
        client_name = @"ios";
    }
    
    NSDictionary *parameters =
    @{  @"email"        :username,
        @"password"     :password,
        @"client_name"  :client_name,
        @"client_id"    :@"7C4B5AC96435EFA0",
        @"client_secret":@"12d950b3c8d447f2ca6c83960fdf371d",
        @"grant_type"   :@"password"};
    
    [AccountNetwork post:apiurl path:@"/api/v1/auth/ncs/authorize" authorization:@"" parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        if (!error) {
            if ([response isKindOfClass:NSDictionary.class]) {
                NSString *code = [response objectForKey:@"code"];
                NSDictionary *data = [response objectForKey:@"data"];
                if (200 == code.integerValue && [data isKindOfClass:NSDictionary.class]) {
                    NSString *token = [data objectForKey:@"access_token"];
                    NSString *type = [data objectForKey:@"token_type"];
                    if ([token isKindOfClass:NSString.class] && [type isKindOfClass:NSString.class]) {
                        NSString *authorization = [NSString stringWithFormat:@"%@ %@", type, token];
                        completion(authorization, nil);
                        return;
                    }
                }
            }
            
            error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        }
        completion(nil, error);
    }];
}

+ (void)revoke:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(completion);
    
    if (0 == authorization.length) {
        NSParameterAssert(apiurl);
        completion(nil); // already revoked.
        return;
    }
    
    [AccountNetwork post:apiurl path:@"/api/v1/auth/ncs/revoke" authorization:authorization parameters:nil completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        if ([response isKindOfClass:NSDictionary.class]) {
            NSString *code = [response objectForKey:@"code"];
            if (code.integerValue == 200) {
                completion(nil);
                return; // OK.
            }
        }
        
        error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        completion(error);
    }];
}

+ (void)passwordchange:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email passwordold:(NSString *)passwordold passwordnew:(NSString *)passwordnew completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSParameterAssert(email && passwordold && passwordnew);
    if (nil == email) email = @"";
    if (nil == passwordold) passwordold = @"";
    if (nil == passwordnew) passwordnew = @"";
    
    NSDictionary *parameters = @{ @"email":email, @"passwordold":passwordold, @"passwordnew":passwordnew };
    
    [AccountNetwork post:apiurl path:@"/api/v1/auth/ncs/passwordchange" authorization:authorization parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        if ([response isKindOfClass:NSDictionary.class]) {
            NSString *code = [response objectForKey:@"code"];
            if (code.integerValue == 200) {
                completion(nil);
                return; // OK.
            }
        }
        
        error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        completion(error);
    }];
}

+ (void)passwordrenew:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSParameterAssert(email);
    if (nil == email) email = @"";
    
    NSDictionary *parameters = @{@"email":email};
    [AccountNetwork post:apiurl path:@"/api/v1/auth/ncs/passwordrenew" authorization:authorization parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        if ([response isKindOfClass:NSDictionary.class]) {
            NSString *code = [response objectForKey:@"code"];
            if (code.integerValue == 200) {
                completion(nil);
                return; // OK.
            }
        }
        
        error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        completion(error);
    }];
}

+ (void)user:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *user, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    [AccountNetwork post:apiurl path:@"/api/v1/user" authorization:authorization parameters:nil completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        if ([response isKindOfClass:NSDictionary.class]) {
            NSDictionary *data = [response objectForKey:@"data"];
            if ([data isKindOfClass:NSDictionary.class]) {
                completion(data, nil);
                return;
            }
        }
        
        error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        completion(nil, error);
    }];
}

+ (void)accepttos:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    NSParameterAssert(email);
    if (email == nil) email = @"";
    
    NSString *date = [self RFC3339DateTimeStringForDate:[NSDate date]];
    NSParameterAssert(date.length > 0);
    
    NSDictionary *parameters = @{@"email":email, @"tos":date};
    [AccountNetwork post:apiurl path:@"/api/v1/user/accepttos" authorization:authorization parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        if ([response isKindOfClass:NSDictionary.class]) {
            NSString *code = [response objectForKey:@"code"];
            if (code.integerValue == 200) {
                completion(nil);
                return; // OK.
            }
        }
        
        error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        completion(error);
    }];
}

+ (NSOperation *)pogopluglogin:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void (^)(NSString *apihost, NSString *token, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    return [AccountNetwork post:apiurl path:@"/api/v1/subscriptions/pogoplug/login" authorization:authorization parameters:nil completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        
        if ([response isKindOfClass:NSDictionary.class]) {
            NSString *code = [response objectForKey:@"code"];
            NSDictionary *data = [response objectForKey:@"data"];
            if (200 == code.integerValue && [data isKindOfClass:NSDictionary.class]) {
                NSString *apihost = [data objectForKey:@"api_host"];
                NSString *token = [data objectForKey:@"token"];
                if ([apihost isKindOfClass:NSString.class] && [token isKindOfClass:NSString.class]) {
                    completion(apihost, token, nil);
                    return; // OK.
                }
            }
        }
        
        error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        completion(nil, nil, error);
    }];
}

+ (void)storageauth:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(int64_t freeSpace, NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(authorization.length > 0);
    
    [AccountNetwork post:apiurl path:@"/api/v1/subscriptions/storage/auth" authorization:authorization parameters:nil completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            completion(0, error);
            return;
        }
        
        if ([response isKindOfClass:NSDictionary.class]) {
            NSString *code = [response objectForKey:@"code"];
            NSParameterAssert(code.integerValue == 200);
            NSDictionary *data = [response objectForKey:@"data"];
            if ([data isKindOfClass:NSDictionary.class]) {
                NSString *apiHost = [data objectForKey:@"api_host"];
                NSParameterAssert([apiHost isKindOfClass:NSString.class]);
                NSString *token = [data objectForKey:@"access_token"];
                NSParameterAssert([token isKindOfClass:NSString.class]);
                NSArray *subscriptions = [data objectForKey:@"subscriptions"];
                if ([subscriptions isKindOfClass:NSArray.class] && subscriptions.count > 0) {
                    NSDictionary *storageSubscription = subscriptions[0];
                    if ([storageSubscription isKindOfClass:NSDictionary.class]) {
                        NSDictionary *storageSpace = [storageSubscription objectForKey:@"space"];
                        if ([storageSpace isKindOfClass:NSDictionary.class]) {
                            id freeValue = [storageSpace objectForKey:@"free"];
                            int64_t freeSpace = 0;
                            if ([freeValue isKindOfClass:NSString.class]) {
                                freeSpace = ((NSString *)freeValue).longLongValue;
                                completion(freeSpace, nil);
                                return;
                            }
                            else if ([freeValue isKindOfClass:NSNumber.class]) {
                                freeSpace = ((NSNumber *)freeValue).longLongValue;
                                completion(freeSpace, nil);
                                return;
                            }
                            else if( [freeValue isKindOfClass:NSNull.class]) {
                                // null indicates unlimited subscprition
                                freeSpace = INT64_MAX;
                                completion(freeSpace, nil);
                                return;
                            }
                        }
                    }
                }
            }
        }
        
        error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        completion(0, error);
    }];
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
