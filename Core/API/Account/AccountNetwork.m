//
//  AccountNetwork.m
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "AccountNetwork.h"
#import "AccountError.h"
#import "AFNetworkReachabilityManager.h"

@implementation AccountNetwork

+ (void)post:(NSURL *)url path:(NSString *)path authorization:(NSString *)authorization parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSParameterAssert(path.length > 0);
    
    if (0 == url.scheme.length || 0 == url.host.length) {
        NSAssert(NO, @"Invalid account base url:(%@).", url);
        NSError *error = [AccountError errorWithCode:AccountError_HostUnspecified];
        completion(nil, error);
        return;
    }
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        NSError *error = [AccountError errorWithCode:AccountError_NetworkNotAvailable];
        completion(nil, error);
        return;
    }
    
    if (!authorization) {
        NSError *error = [AccountError errorWithCode:AccountError_Unauthorized];
        completion(nil, error);
        return;
    }
    
    NSDictionary *header = nil;
    if (authorization.length > 0) {
        header = @{@"authorization":authorization};
    }
    
    // TODO
    // ...
}

@end
