//
//  DatabaseScheme.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "DatabaseScheme.h"

@implementation DatabaseScheme

- (id)initWithBuildNumber:(NSUInteger)buildNumber upgrader:(id)upgrader selector:(SEL)selector;
{
    if (self = [super init]) {
        _buildNumber = buildNumber;
        _upgrader = upgrader;
        _selector = selector;
    }
    return self;
}

+ (NSURL *)storeURLForBuildNumber:(NSUInteger)buildNumber
{
    // TODO
    return nil;
}

+ (NSURL *)modelURLForBuildNumber:(NSUInteger)buildNumber
{
    // TODO
    return nil;
}

@end
