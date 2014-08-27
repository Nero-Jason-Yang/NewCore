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

+ (NSMutableDictionary *)parameters:(NSString *)valtoken
{
    NSParameterAssert(valtoken.length > 0);
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (valtoken) {
        parameters[@"valtoken"] = valtoken;
    }
    return parameters;
}

+ (NSMutableDictionary *)parameters:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
{
    NSParameterAssert(deviceid.length > 0 && serviceid.length > 0);
    NSMutableDictionary *parameters = [self parameters:valtoken];
    if (deviceid) {
        parameters[@"deviceid"] = deviceid;
    }
    if (serviceid) {
        parameters[@"serviceid"] = serviceid;
    }
    return parameters;
}

+ (NSOperation *)listDevices:(NSURL *)apiurl valtoken:(NSString *)valtoken completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [self parameters:valtoken];
    return [PogoplugNetwork get:apiurl path:PogoplugPath_ListDevices parameters:parameters completion:completion];
}

+ (NSOperation *)getFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid filename:(NSString *)filename parentid:(NSString *)parentid completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(fileid || filename);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (filename) {
        parameters[@"filename"] = filename;
    }
    if (parentid) {
        parameters[@"parentid"] = parentid;
    }
    return [PogoplugNetwork get:apiurl path:PogoplugPath_GetFile parameters:parameters completion:completion];
}

+ (NSOperation *)listFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid parentid:(NSString *)parentid offset:(NSUInteger)offset maxcount:(NSUInteger)maxcount showhidden:(BOOL)showhidden sortcrit:(NSString *)sortcrit filtercrit:(NSString *)filtercrit completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(parentid);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
    if (parentid) {
        parameters[@"parentid"] = parentid;
    }
    if (offset > 0) {
        parameters[@"offset"] = @(offset).description;
    }
    if (maxcount > 0) {
        parameters[@"maxcount"] = @(maxcount).description;
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
    return [PogoplugNetwork get:apiurl path:PogoplugPath_ListFiles parameters:parameters completion:completion];
}

+ (NSOperation *)searchFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid searchcrit:(NSString *)searchcrit offset:(NSUInteger)offset maxcount:(NSUInteger)maxcount showhidden:(BOOL)showhidden sortcrit:(NSString *)sortcrit completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(searchcrit);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
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
    return [PogoplugNetwork get:apiurl path:PogoplugPath_SearchFiles parameters:parameters completion:completion];
}

+ (NSOperation *)createFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid filename:(NSString *)filename parentid:(NSString *)parentid type:(NSString *)type mtime:(NSDate *)mtime ctime:(NSDate *)ctime completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(filename);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
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
    return [PogoplugNetwork get:apiurl path:PogoplugPath_CreateFile parameters:parameters completion:completion];
}

+ (NSOperation *)removeFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid recurse:(BOOL)recurse completion:(void (^)(NSError *))completion
{
    NSParameterAssert(fileid);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (recurse) {
        parameters[@"recurse"] = @"1";
    }
    return [PogoplugNetwork get:apiurl path:PogoplugPath_RemoveFile parameters:parameters completion:^(NSDictionary *dictionary, NSError *error) {
        completion(error);
    }];
}

+ (NSOperation *)moveFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid newname:(NSString *)newname completion:(void (^)(NSError *))completion
{
    NSParameterAssert(fileid);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (newname) {
        parameters[@"name"] = newname;
        parameters[@"newname"] = newname;
        parameters[@"filename"] = newname;
    }
    return [PogoplugNetwork get:apiurl path:PogoplugPath_MoveFile parameters:parameters completion:^(NSDictionary *dictionary, NSError *error) {
        completion(error);
    }];
}

+ (NSOperation *)enableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid name:(NSString *)name password:(NSString *)password permissions:(NSString *)permissions completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSParameterAssert(fileid.length > 0);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
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
    return [PogoplugNetwork get:apiurl path:PogoplugPath_EnableShare parameters:parameters completion:completion];
}

+ (NSOperation *)disableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid completion:(void (^)(NSError *))completion
{
    NSParameterAssert(fileid.length > 0);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    return [PogoplugNetwork get:apiurl path:PogoplugPath_DisableShare parameters:parameters completion:^(NSDictionary *dictionary, NSError *error) {
        completion(error);
    }];
}

+ (NSOperation *)sendShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid emails:(NSArray *)emails completion:(void (^)(NSError *))completion
{
    NSParameterAssert(fileid.length > 0 && emails.count > 0);
    NSMutableDictionary *parameters = [self parameters:valtoken deviceid:deviceid serviceid:serviceid];
    if (fileid) {
        parameters[@"fileid"] = fileid;
    }
    if (emails.count > 0) {
        parameters[@"emails"] = [emails componentsJoinedByString:@","];
    }
    return [PogoplugNetwork get:apiurl path:PogoplugPath_SendShare parameters:parameters completion:^(NSDictionary *dictionary, NSError *error) {
        completion(error);
    }];
}

+ (NSOperation *)listShares:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [self parameters:valtoken];
    if (deviceid) {
        parameters[@"deviceid"] = deviceid;
    }
    if (serviceid) {
        parameters[@"serviceid"] = serviceid;
    }
    return [PogoplugNetwork get:apiurl path:PogoplugPath_ListShare parameters:parameters completion:completion];
}

+ (NSOperation *)uploadFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid data:(NSData *)data completion:(void (^)(NSError *))completion
{
    NSURL *fileurl = [self URLForFile:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fileid:fileid flag:nil name:nil];
    return [PogoplugNetwork put:apiurl path:fileurl.path data:data completion:completion];
}

+ (NSOperation *)downloadFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid completion:(void (^)(NSData *, NSError *))completion
{
    NSURL *fileurl = [self URLForFile:apiurl valtoken:valtoken deviceid:deviceid serviceid:serviceid fileid:fileid flag:nil name:nil];
    return [PogoplugNetwork down:apiurl path:fileurl.path completion:completion];
}

+ (NSURL *)URLForFile:(NSURL *)svcurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid fileid:(NSString *)fileid flag:(NSString *)flag name:(NSString *)name
{
    NSParameterAssert(svcurl.absoluteString.length > 0 && valtoken && deviceid && serviceid && fileid);
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
    return [NSURL URLWithPath:path relativeToURL:svcurl];
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
