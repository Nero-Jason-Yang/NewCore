//
//  DatabaseScheme.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "DatabaseScheme.h"

@implementation DatabaseScheme

- (id)initWithBuildNumber:(NSUInteger)buildNumber storeName:(NSString *)storeName modelName:(NSString *)modelName upgrader:(id)upgrader selector:(SEL)selector
{
    if (self = [super init]) {
        _buildNumber = buildNumber;
        _storeName = storeName;
        _modelName = modelName;
        _upgrader = upgrader;
        _selector = selector;
        _storeURL = [DatabaseScheme storeURLWithName:storeName forBuildNumber:buildNumber];
        _modelURL = [DatabaseScheme modelURLWithName:modelName];
    }
    return self;
}

+ (NSURL *)storeURLWithName:(NSString *)name forBuildNumber:(NSUInteger)buildNumber
{
    NSURL *docURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *baseURL = [docURL URLByAppendingPathComponent:@"Database"];
    NSURL *storeURL = [baseURL URLByAppendingPathComponent:[name stringByAppendingFormat:@".%lu", (unsigned long)buildNumber]];
    return [storeURL URLByAppendingPathExtension:@"sqlite"];
}

+ (NSURL *)modelURLWithName:(NSString *)name
{
    return [[NSBundle mainBundle] URLForResource:name withExtension:@"momd"];
}

@end
