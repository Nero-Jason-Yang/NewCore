//
//  NSURL+Utils.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "NSURL+Utils.h"

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
