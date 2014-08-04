//
//  NSError+HTTP.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "NSError+HTTP.h"

@implementation NSError (HTTP)

+ (id)errorWithResponse:(NSHTTPURLResponse *)response
{
    if (![response isKindOfClass:NSHTTPURLResponse.class]) {
        return nil;
    }
    if (response.statusCode < 400) {
        return nil;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSURLErrorKey] = response.URL;
    userInfo[HTTPHeaderFieldsErrorKey] = response.allHeaderFields;
    userInfo[NSLocalizedFailureReasonErrorKey] = [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode];
    return [[NSError alloc] initWithDomain:HTTPErrorDomain code:response.statusCode userInfo:userInfo];
}

@end
