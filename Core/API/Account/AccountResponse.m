//
//  AccountResponse.m
//  NewCore
//
//  Created by Jason Yang on 14-9-2.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "AccountResponse.h"

@implementation AccountResponse

- (NSNumber *)code
{
    return [self integerValueForKey:@"code"];
}

- (NSString *)message
{
    return [self stringValueForKey:@"message"];
}

@end

@implementation AccountResponse_Authorize
{
    DictionaryReader *_data;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        _data = [self readerValueForKey:@"data" class:[DictionaryReader class]];
    }
    return self;
}

- (NSString *)access_token
{
    return [_data stringValueForKey:@"access_token"];
}

- (NSString *)token_type
{
    return [_data stringValueForKey:@"token_type"];
}

- (NSString *)authorization
{
    NSString *token = self.access_token;
    NSString *type = self.token_type;
    if (token && type) {
        return [NSString stringWithFormat:@"%@ %@", type, token];
    }
    return nil;
}

@end

@implementation AccountResponse_PogoplugLogin
{
    DictionaryReader *_data;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        _data = [self readerValueForKey:@"data" class:[DictionaryReader class]];
    }
    return self;
}

- (NSString *)token
{
    return [_data stringValueForKey:@"token"];
}

- (NSString *)api_host
{
    return [_data stringValueForKey:@"api_host"];
}

- (NSString *)webclient_url
{
    return [_data stringValueForKey:@"webclient_url"];
}

- (NSArray *)subscriptions
{
    return [_data readerArrayValueForKey:@"subscriptions" class:[AccountResponseValue_Subscription class]];
}

@end

@implementation AccountResponse_StorageAuth
{
    DictionaryReader *_data;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        _data = [self readerValueForKey:@"data" class:[DictionaryReader class]];
    }
    return self;
}

- (NSString *)api_host
{
    return [_data stringValueForKey:@"api_host"];
}

- (NSString *)access_token
{
    return [_data stringValueForKey:@"access_token"];
}

- (NSString *)token_type
{
    return [_data stringValueForKey:@"token_type"];
}

- (NSNumber *)expires_in
{
    return [_data integerValueForKey:@"expires_in"];
}

- (NSArray *)subscriptions
{
    return [_data readerArrayValueForKey:@"subscriptions" class:[AccountResponseValue_Subscription class]];
}

@end

@implementation AccountResponseValue_Subscription

- (NSNumber *)ID
{
    return [self integerValueForKey:@"id"];
}

- (NSString *)provider
{
    return [self stringValueForKey:@"provider"];
}

- (NSString *)type
{
    return [self stringValueForKey:@"type"];
}

- (NSString *)provider_id
{
    return [self stringValueForKey:@"provider_id"];
}

- (NSDate *)creationdate
{
    return [self dateValueForKey:@"creationdate"];
}

- (NSDate *)expirationdate
{
    return [self dateValueForKey:@"expirationdate"];
}

- (NSString *)state
{
    return [self stringValueForKey:@"state"];
}

- (NSString *)source
{
    return [self stringValueForKey:@"source"];
}

- (AccountResponseValue_SubscriptionPlan *)plan
{
    return [self readerValueForKey:@"plan" class:[AccountResponseValue_SubscriptionPlan class]];
}

- (AccountResponseValue_SubscriptionSpace *)space
{
    return [self readerValueForKey:@"space" class:[AccountResponseValue_SubscriptionSpace class]];
}

@end

@implementation AccountResponseValue_SubscriptionPlan

- (NSNumber *)ID
{
    return [self integerValueForKey:@"id"];
}

- (NSString *)provider
{
    return [self stringValueForKey:@"provider"];
}

- (NSString *)type
{
    return [self stringValueForKey:@"type"];
}

- (NSString *)provplanid
{
    return [self stringValueForKey:@"provplanid"];
}

- (NSString *)name
{
    return [self stringValueForKey:@"name"];
}

- (AccountResponseValue_SubscriptionPlanDetails *)details
{
    return [self readerValueForKey:@"details" class:[AccountResponseValue_SubscriptionPlanDetails class]];
}

@end

@implementation AccountResponseValue_SubscriptionPlanDetails

- (NSNumber *)capacity
{
    return [self longLongValueForKey:@"capacity"];
}

- (NSNumber *)all_features
{
    return [self boolValueForKey:@"all_features"];
}

@end

@implementation AccountResponseValue_SubscriptionSpace

- (NSNumber *)free
{
    return [self longLongValueForKey:@"free"];
}

- (NSNumber *)used
{
    return [self longLongValueForKey:@"used"];
}

- (NSNumber *)capacity
{
    return [self longLongValueForKey:@"capacity"];
}

@end
