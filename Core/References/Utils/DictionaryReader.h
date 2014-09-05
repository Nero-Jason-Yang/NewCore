//
//  DictionaryReader.h
//  NewCore
//
//  Created by Jason Yang on 14-9-5.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryReader : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic,readonly) NSDictionary *dictionary;

- (id)readerValueForKey:(NSString *)key class:(Class)class;
- (NSArray *)readerArrayValueForKey:(NSString *)key class:(Class)class;

- (NSString *)stringValueForKey:(NSString *)key;
- (NSNumber *)integerValueForKey:(NSString *)key;
- (NSNumber *)longLongValueForKey:(NSString *)key;
- (NSNumber *)boolValueForKey:(NSString *)key;
- (NSDate *)dateValueForKey:(NSString *)key;

@end
