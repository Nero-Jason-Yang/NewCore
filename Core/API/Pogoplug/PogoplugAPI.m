//
//  PogoplugAPI.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "PogoplugAPI.h"
#import "PogoplugError.h"
#import "AFNetworkReachabilityManager.h"
#import "PogoplugOperationManager.h"

@implementation PogoplugAPI

+ (NSError *)checkParameters:(NSURL *)host valtoken:(NSString *)valtoken fillRequestParameters:(NSMutableDictionary *)parameters
{
    NSParameterAssert([host isKindOfClass:NSURL.class]);
    NSParameterAssert([valtoken isKindOfClass:NSString.class] && valtoken.length > 0);
    NSParameterAssert([parameters isKindOfClass:NSMutableDictionary.class]);
    
    if (![host isKindOfClass:NSURL.class]) {
        return [PogoplugError error:PogoplugError_HostUnspecified];
    }
    
    if (0 == valtoken.length) {
        return [PogoplugError error:PogoplugError_Unauthorized];
    }
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        return [PogoplugError error:PogoplugError_NetworkNotAvailable];
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
        return [PogoplugError error:PogoplugError_Unknown];
    }
    
    if (parameters) {
        parameters[@"deviceid"] = deviceid;
        parameters[@"serviceid"] = serviceid;
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

+ (NSError *)listDevices:(NSURL *)apiurl valtoken:(NSString *)valtoken result:(NSDictionary **)result
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken fillRequestParameters:parameters];
    if (error) {
        return error;
    }
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"listDevices" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    NSDictionary *json = [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (result) {
        *result = json;
    }
    return nil;
}

+ (NSError *)getFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid filename:(NSString *)filename parentid:(NSString *)parentid result:(NSDictionary **)result
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
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
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"getFile" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    NSDictionary *json = [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (result) {
        *result = json;
    }
    return nil;
}

+ (NSError *)listFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid parentid:(NSString *)parentid offset:(NSUInteger)offset maxcount:(NSUInteger)maxcount showhidden:(BOOL)showhidden sortcrit:(NSString *)sortcrit filtercrit:(NSString *)filtercrit result:(NSDictionary **)result
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
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
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"listFiles" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    NSDictionary *json = [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (result) {
        *result = json;
    }
    return nil;
}

+ (NSError *)searchFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid searchcrit:(NSString *)searchcrit offset:(NSUInteger)offset maxcount:(NSUInteger)maxcount showhidden:(BOOL)showhidden sortcrit:(NSString *)sortcrit result:(NSDictionary **)result
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
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
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"searchFiles" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    NSDictionary *json = [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (result) {
        *result = json;
    }
    return nil;
}

+ (NSError *)createFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid filename:(NSString *)filename parentid:(NSString *)parentid type:(NSString *)type mtime:(NSDate *)mtime ctime:(NSDate *)ctime result:(NSDictionary **)result
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
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
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"json/createFile" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    NSDictionary *json = [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (result) {
        *result = json;
    }
    return nil;
}

+ (NSError *)removeFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid recurse:(BOOL)recurse
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
    }
    
    NSParameterAssert(fileid);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (recurse) {
        parameters[@"recurse"] = @"1";
    }
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"json/removeFile" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)moveFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid newname:(NSString *)newname
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
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
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"json/moveFile" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)enableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid name:(NSString *)name password:(NSString *)password permissions:(NSString *)permissions result:(NSDictionary **)result
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
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
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"json/enableShare" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    NSDictionary *json = [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (result) {
        *result = json;
    }
    return nil;
}

+ (NSError *)disableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
    }
    
    NSParameterAssert(fileid.length > 0);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"json/disableShare" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)sendShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid emails:(NSArray *)emails
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:parameters];
    if (error) {
        return error;
    }
    
    NSParameterAssert(fileid.length > 0 && emails.count > 0);
    
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (emails.count > 0) {
        parameters[@"emails"] = [emails componentsJoinedByString:@","];
    }
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"json/sendShare" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)listShares:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid result:(NSDictionary **)result
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSError *error = [self checkParameters:apiurl valtoken:valtoken fillRequestParameters:parameters];
    if (error) {
        return error;
    }
    
    if (deviceid) {
        parameters[@"deviceid"] = deviceid;
    }
    if (serviceid) {
        parameters[@"serviceid"] = serviceid;
    }
    
    NSParameterAssert([apiurl.absoluteString.lastPathComponent isEqualToString:@"api"]);
    NSURL *url = [NSURL URLWithPath:@"json/listShares" relativeToURL:apiurl];
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:url.baseURL];
    NSDictionary *json = [manager GET:url.path parameters:parameters operation:nil error:&error];
    if (error) {
        return error;
    }
    
    if (![json isKindOfClass:NSDictionary.class]) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (result) {
        *result = json;
    }
    return nil;
}

+ (NSError *)getFileURL:(NSURL *)svcurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid flag:(opt NSString *)flag name:(opt NSString *)name result:(out NSURL **)result
{
    NSError *error = [self checkParameters:svcurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fillRequestParameters:nil];
    if (error) {
        return error;
    }
    
    NSParameterAssert(fileid.length > 0);
    
    if (result) {
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
        
        *result = [NSURL URLWithPath:path relativeToURL:svcurl];
    }
    return nil;
}

@end
