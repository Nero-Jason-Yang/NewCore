//
//  NSBundle+Utils.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "NSBundle+Utils.h"

@implementation NSBundle (Utils)

- (NSString *)bundleVersion
{
    return [self.bundleVersionShort stringByAppendingPathExtension:self.buildNumberString];
}

- (NSString *)bundleVersionShort
{
    return [self objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)buildNumberString
{
    return [self objectForInfoDictionaryKey:(__bridge_transfer NSString *)kCFBundleVersionKey];
}

- (NSUInteger)buildNumber
{
    return self.buildNumberString.integerValue;
}

@end
