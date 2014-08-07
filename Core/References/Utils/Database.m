//
//  Database.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Database.h"

@implementation Database

- (id)init
{
    if (self = [super init]) {
        [self upgrade];
        [self create];
    }
    return self;
}

- (NSArray *)allSchemes
{
    NSAssert(NO, @"must but not override [Database allSchemes]!");
    return @[];
}

- (NSError *)upgrade:(DatabaseScheme *)from to:(DatabaseScheme *)to
{
    NSAssert(NO, @"must but not override [Database upgradeTo:from:]!");
    return nil;
}

- (NSError *)upgrade
{
    NSArray *schemes = self.allSchemes;
    NSUInteger i = 0, count = schemes.count;
    
    // find scheme index that its database store file is existed.
    for (; i < count; i ++) {
        DatabaseScheme *scheme = schemes[i];
        NSParameterAssert([scheme isKindOfClass:DatabaseScheme.class]);
        NSString *path = scheme.storeURL.path;
        NSParameterAssert(path.length > 0);
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            break;
        }
    }
    
    if (i < count) {
        for (; i > 0; i --) {
            DatabaseScheme *from = schemes[i];
            DatabaseScheme *to = schemes[i-1];
            
            NSError *error = [self upgrade:from to:to];
            if (error) {
                return error;
            }
            
            [[NSFileManager defaultManager] removeItemAtURL:from.storeURL error:nil];
        }
    }
    
    return nil;
}

- (NSError *)create
{
    // TODO
    _context = nil;
    return nil;
}

@end


@implementation DatabaseScheme

- (id)initWithBuildNumber:(NSUInteger)buildNumber storeName:(NSString *)storeName modelName:(NSString *)modelName
{
    if (self = [super init]) {
        _buildNumber = buildNumber;
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
