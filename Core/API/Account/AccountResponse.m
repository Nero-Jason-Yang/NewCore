//
//  AccountResponse.m
//  NewCore
//
//  Created by Jason Yang on 14-9-2.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "AccountResponse.h"

@implementation DictionaryReader

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _dictionary = dictionary;
    }
    return self;
}

@end

@implementation AccountResponse

- (NSInteger)code
{
    NSString *value = self.dictionary[@"code"];
    if ([value isKindOfClass:[NSString class]]) {
        return value.integerValue;
    }
    return 0;
}

- (NSString *)message
{
    NSString *value = self.dictionary[@"message"];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
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
    NSDictionary *_data;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        NSDictionary *data = self.data;
        if ([data isKindOfClass:[NSDictionary class]]) {
            _data = data;
        }
    }
    return self;
}

- (NSString *)access_token
{
    NSString *value = _data[@"access_token"];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}

- (NSString *)token_type
{
    NSString *value = _data[@"token_type"];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
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
    NSDictionary *_data;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        NSDictionary *data = self.data;
        if ([data isKindOfClass:[NSDictionary class]]) {
            _data = data;
        }
    }
    return self;
}

- (NSString *)token
{
    NSString *value = _data[@"token"];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}

- (NSString *)api_host
{
    NSString *value = _data[@"api_host"];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}

- (NSString *)webclient_url
{
    NSString *value = _data[@"webclient_url"];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}

- (NSArray *)subscriptions
{
    NSArray *subscriptions = self.dictionary[@"subscriptions"];
    if (![subscriptions isKindOfClass:[NSArray class]]) {
        return nil;
    }
    // TODO
}

@end
