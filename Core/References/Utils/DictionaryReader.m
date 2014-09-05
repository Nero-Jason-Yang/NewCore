//
//  DictionaryReader.m
//  NewCore
//
//  Created by Jason Yang on 14-9-5.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "DictionaryReader.h"

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
