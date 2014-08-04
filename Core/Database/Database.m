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

- (NSArray *)allSchemes
{
    static NSArray *schemes = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        schemes = @[[[DatabaseScheme alloc] initWithBuildNumber:0 upgrader:self selector:@selector(setupDatabase)],
                    [[DatabaseScheme alloc] initWithBuildNumber:2 upgrader:self selector:@selector(upgradeDatabase2)],
                    ];
    });
    
    return schemes;
}

- (id)init
{
    if (self = [super init]) {
        [self tryUpgradeDatabaseWithSchemes:[self allSchemes] at:0];
    }
    return self;
}

- (void)tryUpgradeDatabaseWithSchemes:(NSArray *)schemes at:(NSUInteger)index
{
    if (index < schemes.count) {
        DatabaseScheme *scheme = schemes[index];
        NSURL *storeURL = scheme.storeURL;
        if (storeURL) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
                [self tryUpgradeDatabaseWithSchemes:schemes at:index+1];
                if ([scheme.upgrader respondsToSelector:scheme.selector]) {
                    [scheme.upgrader performSelector:scheme.selector];
                }
            }
        }
    }
}

#pragma mark database upgraders

- (void)setupDatabase
{
    
}

- (void)upgradeDatabase2
{
    
}

@end
