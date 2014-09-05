//
//  AccountResponse.m
//  NewCore
//
//  Created by Jason Yang on 14-9-2.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "AccountResponse.h"

@interface DictionaryReader ()
- (NSNumber *)integerValueForKey:(NSString *)key;
@end

@implementation DictionaryReader

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _dictionary = dictionary;
    }
    return self;
}

- (id)readerValueForKey:(NSString *)key class:(Class)class
{
    NSParameterAssert(key);
    id value = self.dictionary[key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [[class alloc] initWithDictionary:value];
    }
    return nil;
}

- (NSArray *)readerArrayValueForKey:(NSString *)key class:(Class)class
{
    NSParameterAssert(key);
    NSArray *value = self.dictionary[key];
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dictionary in value) {
            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                [array addObject:[[class alloc] initWithDictionary:dictionary]];
            }
        }
        return array;
    }
    return nil;
}

- (NSString *)stringValueForKey:(NSString *)key
{
    NSParameterAssert(key);
    id value = self.dictionary[key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}

- (NSNumber *)integerValueForKey:(NSString *)key
{
    NSParameterAssert(key);
    id value = self.dictionary[key];
    if ([value isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithInteger:((NSString *)value).integerValue];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSNumber numberWithInteger:((NSNumber *)value).integerValue];
    }
    return nil;
}

- (NSNumber *)longLongValueForKey:(NSString *)key
{
    NSParameterAssert(key);
    id value = self.dictionary[key];
    if ([value isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithLongLong:((NSString *)value).longLongValue];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSNumber numberWithLongLong:((NSNumber *)value).longLongValue];
    }
    return nil;
}

- (NSNumber *)boolValueForKey:(NSString *)key
{
    NSParameterAssert(key);
    id value = self.dictionary[key];
    if ([value isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithBool:((NSString *)value).boolValue];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSNumber numberWithBool:((NSNumber *)value).boolValue];
    }
    return nil;
}

- (NSDate *)dateValueForKey:(NSString *)key
{
    NSParameterAssert(key);
    id value = self.dictionary[key];
    if ([value isKindOfClass:[NSString class]]) {
        // TODO
        NSAssert(0, @"not implemented!");
        return nil;
    }
    return nil;
}

@end

@implementation AccountResponse

- (NSNumber *)code
{
    return [self integerValueForKey:@"code"];
}

- (NSString *)message
{
    return [self stringValueForKey:@"message"];
}

- (id)details
{
    return self.dictionary[@"details"];
}

- (id)data
{
    return self.dictionary[@"data"];
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

@end

@implementation AccountResponse_Authorize (Advance)

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
    return [_data readerArrayValueForKey:@"subscriptions" class:[AccountResponseData_Subscription class]];
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
    return [_data readerArrayValueForKey:@"subscriptions" class:[AccountResponseData_Subscription class]];
}

@end

@implementation AccountResponseData_Subscription

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

- (AccountResponseData_SubscriptionPlan *)plan
{
    return [self readerValueForKey:@"plan" class:[AccountResponseData_SubscriptionPlan class]];
}

- (AccountResponseData_SubscriptionSpace *)space
{
    return [self readerValueForKey:@"space" class:[AccountResponseData_SubscriptionSpace class]];
}

@end

@implementation AccountResponseData_SubscriptionPlan

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

- (AccountResponseData_SubscriptionPlanDetails *)details
{
    return [self readerValueForKey:@"details" class:[AccountResponseData_SubscriptionPlanDetails class]];
}

@end

@implementation AccountResponseData_SubscriptionPlanDetails

- (NSNumber *)capacity
{
    return [self longLongValueForKey:@"capacity"];
}

- (NSNumber *)all_features
{
    return [self boolValueForKey:@"all_features"];
}

@end

@implementation AccountResponseData_SubscriptionSpace

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
