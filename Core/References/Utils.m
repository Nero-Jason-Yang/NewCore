//
//  Utils.m
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Utils.h"

@implementation Utils

@end

@implementation NSURL (Utils)

+ (NSURL *)URLWithPath:(NSString *)path relativeToURL:(NSURL *)url
{
    if (0 == path) {
        return url.absoluteURL;
    }
    
    if ([path hasPrefix:@"/"]) {
        return [[NSURL URLWithString:path relativeToURL:url] absoluteURL];
    }
    
    return [url URLByAppendingPathComponent:path];
}

+ (NSURL *)URLWithScheme:(NSString *)scheme relativeToURL:(NSURL *)url
{
    if (0 == scheme) {
        return [NSURL URLWithString:[url.host stringByAppendingPathComponent:url.path]];
    }
    
    return [[NSURL alloc] initWithScheme:scheme host:url.host path:url.path];
}

@end

@implementation NSDate (Pogoplug)

+ (id)dateWithPogoplugTimeString:(NSString *)string
{
    return [NSDate dateWithTimeIntervalSince1970:string.longLongValue/1000.0];
}

- (NSString *)pogoplugTimeString
{
    long long value = (long long)(self.timeIntervalSince1970 * 1000.0);
    return [NSString stringWithFormat:@"%lld", value];
}

@end

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