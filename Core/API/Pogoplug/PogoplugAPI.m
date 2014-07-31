//
//  PogoplugAPI.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Core.h"
#import "PogoplugAPI.h"
#import "PogoplugNetwork.h"

#import "AFNetworkReachabilityManager.h"

@implementation PogoplugAPI

+ (void)listDevices:(NSURL *)apiurl valtoken:(NSString *)valtoken completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken fillRequestParameters:parameters];
    if (error) {
        completion(nil, error);
        return;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_ListDevices parameters:parameters completion:completion];
}

+ (void)getFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid filename:(NSString *)filename parentid:(NSString *)parentid completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(nil, error);
        return;
    }
    
    NSParameterAssert(fileid || filename);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (filename) {
        parameters[@"filename"] = filename;
    }
    if (parentid) {
        parameters[@"parentid"] = parentid;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_GetFile parameters:parameters completion:completion];
}

+ (void)listFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid parentid:(NSString *)parentid offset:(NSUInteger)offset maxcount:(NSUInteger)maxcount showhidden:(BOOL)showhidden sortcrit:(NSString *)sortcrit filtercrit:(NSString *)filtercrit completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(nil, error);
        return;
    }
    
    NSParameterAssert(parentid);
    
    if (parentid) {
        parameters[@"parentid"] = parentid;
    }
    if (offset > 0) {
        parameters[@"offset"] = [NSNumber numberWithUnsignedInteger:offset].description;
    }
    if (maxcount > 0) {
        parameters[@"maxcount"] = [NSNumber numberWithUnsignedInteger:maxcount].description;
    }
    if (showhidden) {
        parameters[@"showhidden"] = @"true";
    }
    if (sortcrit) {
        parameters[@"sortcrit"] = sortcrit;
    }
    if (filtercrit) {
        parameters[@"filtercrit"] = filtercrit;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_ListFiles parameters:parameters completion:completion];
}

+ (void)searchFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid searchcrit:(NSString *)searchcrit offset:(NSUInteger)offset maxcount:(NSUInteger)maxcount showhidden:(BOOL)showhidden sortcrit:(NSString *)sortcrit completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(nil, error);
        return;
    }
    
    NSParameterAssert(searchcrit);
    
    if (searchcrit) {
        parameters[@"searchcrit"] = searchcrit;
    }
    if (offset > 0) {
        parameters[@"offset"] = [NSNumber numberWithUnsignedInteger:offset].description;
    }
    if (maxcount > 0) {
        parameters[@"maxcount"] = [NSNumber numberWithUnsignedInteger:maxcount].description;
    }
    if (showhidden) {
        parameters[@"showhidden"] = @"true";
    }
    if (sortcrit) {
        parameters[@"sortcrit"] = sortcrit;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_SearchFiles parameters:parameters completion:completion];
}

+ (void)createFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid filename:(NSString *)filename parentid:(NSString *)parentid type:(NSString *)type mtime:(NSDate *)mtime ctime:(NSDate *)ctime completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(nil, error);
        return;
    }
    
    NSParameterAssert(filename);
    
    if (filename) {
        parameters[@"filename"] = filename;
    }
    if (parentid) {
        parameters[@"parentid"] = parentid;
    }
    if (type) {
        parameters[@"type"] = type;
    }
    if (mtime) {
        parameters[@"mtime"] = [self stringWithDate:mtime];
    }
    if (ctime) {
        parameters[@"ctime"] = [self stringWithDate:ctime];
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_CreateFile parameters:parameters completion:completion];
}

+ (void)removeFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid recurse:(BOOL)recurse completion:(void (^)(NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(error);
        return;
    }
    
    NSParameterAssert(fileid);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (recurse) {
        parameters[@"recurse"] = @"1";
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_RemoveFile parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        completion(error);
    }];
}

+ (void)moveFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid newname:(NSString *)newname completion:(void (^)(NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(error);
        return;
    }
    
    NSParameterAssert(fileid);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (newname) {
        parameters[@"name"] = newname;
        parameters[@"newname"] = newname;
        parameters[@"filename"] = newname;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_MoveFile parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        completion(error);
    }];
}

+ (void)enableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid name:(NSString *)name password:(NSString *)password permissions:(NSString *)permissions completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(nil, error);
        return;
    }
    
    NSParameterAssert(fileid.length > 0);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (name) {
        parameters[@"name"] = name;
    }
    if (password) {
        parameters[@"password"] = password;
    }
    if (permissions) {
        parameters[@"permissions"] = permissions;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_EnableShare parameters:parameters completion:completion];
}

+ (void)disableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid completion:(void (^)(NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(error);
        return;
    }
    
    NSParameterAssert(fileid.length > 0);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_DisableShare parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        completion(error);
    }];
}

+ (void)sendShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid emails:(NSArray *)emails completion:(void (^)(NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        completion(error);
        return;
    }
    
    NSParameterAssert(fileid.length > 0 && emails.count > 0);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (emails.count > 0) {
        parameters[@"emails"] = [emails componentsJoinedByString:@","];
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_SendShare parameters:parameters completion:^(NSDictionary *response, NSError *error) {
        completion(error);
    }];
}

+ (void)listShares:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken fillRequestParameters:parameters];
    if (error) {
        completion(nil, error);
        return;
    }
    
    if (deviceid) {
        parameters[@"deviceid"] = deviceid;
    }
    if (serviceid) {
        parameters[@"serviceid"] = serviceid;
    }
    
    [PogoplugNetwork get:apiurl path:PogoplugPath_ListShare parameters:parameters completion:completion];
}

#pragma mark utils

+ (void)uploadFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid data:(NSData *)data completion:(void (^)(NSError *))completion
{
    NSURL *fileurl = nil;
    NSError *error = [self getFileURL:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fileid:fileid flag:nil name:nil fileurl:&fileurl];
    if (error) {
        completion(error);
        return;
    }
    
    [PogoplugNetwork put:apiurl path:fileurl.path data:data completion:completion];
}

+ (void)downloadFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid completion:(void (^)(NSData *, NSError *))completion
{
    NSURL *fileurl = nil;
    NSError *error = [self getFileURL:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fileid:fileid flag:nil name:nil fileurl:&fileurl];
    if (error) {
        completion(nil, error);
        return;
    }
    
    [PogoplugNetwork down:apiurl path:fileurl.path completion:completion];
}

+ (NSError *)checkParameters:(NSURL *)host valtoken:(NSString *)valtoken fillRequestParameters:(NSMutableDictionary *)parameters
{
    NSParameterAssert([host isKindOfClass:NSURL.class]);
    NSParameterAssert([valtoken isKindOfClass:NSString.class] && valtoken.length > 0);
    NSParameterAssert([parameters isKindOfClass:NSMutableDictionary.class]);
    
    if (![host isKindOfClass:NSURL.class]) {
        return [CoreError errorWithCode:Error_Unexpected underlyingError:nil method:@"PogoplugAPI" comment:@"api url not specified" file:__FILE__ line:__LINE__];
    }
    
    if (0 == valtoken.length) {
        return [CoreError errorWithCode:Error_Unauthorized underlyingError:nil method:@"PogoplugAPI" comment:@"token not specified." file:__FILE__ line:__LINE__];
    }
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        return [CoreError errorWithCode:Error_NetworkUnavailable underlyingError:nil method:@"PogoplugAPI" comment:@"Network not reachable." file:__FILE__ line:__LINE__];
    }
    
    if (parameters) {
        parameters[@"valtoken"] = valtoken;
    }
    
    return nil;
}

+ (NSError *)checkParameters:(NSURL *)host valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fillRequestParameters:(NSMutableDictionary *)parameters
{
    NSError *error = [self checkParameters:host valtoken:valtoken fillRequestParameters:parameters];
    if (error) {
        return error;
    }
    
    NSParameterAssert(deviceid.length > 0 && serviceid.length > 0);
    
    if (0 == deviceid.length || 0 == serviceid.length) {
        // TODO
        // report to GA.
        return [CoreError errorWithCode:Error_Unexpected underlyingError:nil method:@"PogoplugAPI" comment:@"deviceid or serviceid not specified." file:__FILE__ line:__LINE__];
    }
    
    if (parameters) {
        parameters[@"deviceid"] = deviceid;
        parameters[@"serviceid"] = serviceid;
    }
    
    return nil;
}

+ (NSError *)getFileURL:(NSURL *)svcurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid flag:(NSString *)flag name:(NSString *)name fileurl:(out NSURL **)fileurl
{
    NSError *error = [self checkParameters:svcurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:nil];
    if (error) {
        return error;
    }
    
    NSParameterAssert(fileid.length > 0);
    
    if (fileurl) {
        NSString *path = @"/svc/files";
        if (valtoken) {
            path = [path stringByAppendingPathComponent:valtoken];
        }
        if (deviceid) {
            path = [path stringByAppendingPathComponent:deviceid];
        }
        if (serviceid) {
            path = [path stringByAppendingPathComponent:serviceid];
        }
        if (fileid) {
            path = [path stringByAppendingPathComponent:fileid];
        }
        if (flag) {
            path = [path stringByAppendingPathComponent:flag];
        }
        if (name) {
            path = [path stringByAppendingPathComponent:name];
        }
        
        *fileurl = [NSURL URLWithPath:path relativeToURL:svcurl];
    }
    return nil;
}

+ (NSString *)stringWithDate:(NSDate *)date
{
    long long value = (long long)(date.timeIntervalSince1970 * 1000.0);
    return [NSNumber numberWithLongLong:value].description;
}

+ (NSDate *)dateWithString:(NSString *)string
{
    return [NSDate dateWithTimeIntervalSince1970:string.longLongValue/1000.0];
}

@end
