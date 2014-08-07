//
//  Database.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Database.h"
#import "DatabaseScheme.h"

@implementation Database

+ (Database *)database
{
    static Database *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Database alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        [self tryUpgradeDatabaseWithSchemes:[self allSchemes] at:0];
    }
    return self;
}

- (NSArray *)allSchemes
{
    NSArray *schemes =
    @[[[DatabaseScheme alloc] initWithBuildNumber:1 storeName:@"Database" modelName:@"Database" upgrader:self selector:@selector(upgradeDatabase1:)],
      [[DatabaseScheme alloc] initWithBuildNumber:0 storeName:@"Database" modelName:@"Database" upgrader:self selector:@selector(setupDatabase:)]];
    return schemes;
}

- (void)tryUpgradeDatabaseWithSchemes:(NSArray *)schemes at:(NSUInteger)index
{
    if (index >= schemes.count) {
        return; // finished trying all schemes.
    }
    
    // get scheme.
    DatabaseScheme *scheme = schemes[index];
    NSParameterAssert([scheme isKindOfClass:DatabaseScheme.class]);
    NSString *path = scheme.storeURL.path;
    NSParameterAssert(path.length > 0);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return; // database at index already created.
    }
    
    // try to upgrade database to previous scheme.
    [self tryUpgradeDatabaseWithSchemes:schemes at:index+1];
    
    // upgrade database with scheme.
    NSParameterAssert(scheme.upgrader && scheme.selector);
    NSParameterAssert([scheme.upgrader respondsToSelector:scheme.selector]);
    if ([scheme.upgrader respondsToSelector:scheme.selector]) {
        _PerformSelectorBegin
        [scheme.upgrader performSelector:scheme.selector withObject:scheme];
        _PerformSelectorEnd
        return;
    }
}

#pragma mark database upgraders

- (void)setupDatabase:(DatabaseScheme *)scheme
{
    // TODO
}

- (void)upgradeDatabase1:(DatabaseScheme *)scheme
{
    // TODO
}

@end
