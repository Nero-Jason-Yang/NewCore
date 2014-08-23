//
//  AccountParameters.m
//  NewCore
//
//  Created by Yang Jason on 14-8-23.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "AccountParameters.h"

@implementation AccountParameters

- (id)copy
{
    AccountParameters *copy = [[AccountParameters alloc] init];
    copy.baseurl = self.baseurl;
    copy.username = self.username;
    copy.authorization = self.authorization;
    return copy;
}

@end
