//
//  PogoplugParameters.m
//  NewCore
//
//  Created by Yang Jason on 14-8-23.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "PogoplugParameters.h"

@implementation PogoplugParameters

- (id)copy
{
    PogoplugParameters *copy = [[PogoplugParameters alloc] init];
    copy.locker = self.locker;
    copy.apiurl = self.apiurl;
    copy.valtoken = self.valtoken;
    copy.tokendate = self.tokendate;
    copy.svcurl = self.svcurl;
    copy.deviceid = self.deviceid;
    copy.serviceid = self.serviceid;
    return copy;
}

- (void)reset:(PogoplugParameters *)params
{
    self.locker = params.locker;
    self.apiurl = params.apiurl;
    self.valtoken = params.valtoken;
    self.tokendate = params.tokendate;
    self.svcurl = params.svcurl;
    self.deviceid = params.deviceid;
    self.serviceid = params.serviceid;
}

@end
