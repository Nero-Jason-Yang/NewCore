//
//  BackupDatabase.m
//  NewCore
//
//  Created by Jason Yang on 14-8-7.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupDatabase.h"

@implementation BackupDatabase

#pragma mark database upgrading

// override [Database allSchemes]
- (NSArray *)allSchemes
{
    NSArray *schemes =
    @[[[DatabaseScheme alloc] initWithBuildNumber:1 storeName:@"Backup" modelName:@"Backup"],
      [[DatabaseScheme alloc] initWithBuildNumber:0 storeName:@"Backup" modelName:@"Backup"]];
    return schemes;
}

- (NSError *)upgrade:(DatabaseScheme *)from to:(DatabaseScheme *)to
{
    // TODO
    return nil;
}

@end
