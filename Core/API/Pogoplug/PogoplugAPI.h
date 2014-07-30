//
//  PogoplugAPI.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PogoplugFile_NormalFile        @"0"
#define PogoplugFile_Directory         @"1"
#define PogoplugFile_SymbolicLink      @"3"
#define PogoplugFile_MusicAlbum        @"10"
#define PogoplugFile_MusicArtist       @"11"
#define PogoplugFile_MusicGenre        @"12"
#define PogoplugFile_MusicPlaylist     @"13"
#define PogoplugFile_PhotoTimeline     @"20"
#define PogoplugFile_PhotoAlbum        @"21"
#define PogoplugFile_PhotoFace         @"22"
#define PogoplugFile_VideoTimeline     @"30"
#define PogoplugFile_VideoAlbum        @"31"
#define PogoplugFile_GenericCollection @"101"
#define PogoplugFile_OriginCollection  @"102"

#define PogoplugFlag_Thumbnail         @"tn"
#define PogoplugFlag_Preview           @"pv"
#define PogoplugFlag_Stream            @"st"

#define PogoplugStreamType_Full        @"full"

#define PogoplugPath_ListDevices  @"/svc/api/listDevices"
#define PogoplugPath_GetFile      @"/svc/api/getFile"
#define PogoplugPath_ListFiles    @"/svc/api/listFiles"
#define PogoplugPath_SearchFiles  @"/svc/api/searchFiles"
#define PogoplugPath_CreateFile   @"/svc/api/json/createFile"
#define PogoplugPath_RemoveFile   @"/svc/api/json/removeFile"
#define PogoplugPath_MoveFile     @"/svc/api/json/moveFile"
#define PogoplugPath_EnableShare  @"/svc/api/json/enableShare"
#define PogoplugPath_DisableShare @"/svc/api/json/disableShare"
#define PogoplugPath_SendShare    @"/svc/api/json/sendShare"
#define PogoplugPath_ListShare    @"/svc/api/json/listShare"

@interface PogoplugAPI : NSObject

+ (void) listDevices:(NSURL *)apiurl valtoken:(NSString *)valtoken
          completion:(void(^)(NSDictionary *response, NSError *error))completion;

+ (void)     getFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(opt NSString *)fileid filename:(opt NSString *)filename parentid:(opt NSString *)parentid
          completion:(void(^)(NSDictionary *response, NSError *error))completion;

+ (void)   listFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
            parentid:(NSString *)parentid offset:(opt NSUInteger)offset maxcount:(opt NSUInteger)maxcount
          showhidden:(opt BOOL)showhidden sortcrit:(opt NSString *)sortcrit filtercrit:(opt NSString *)filtercrit
          completion:(void(^)(NSDictionary *response, NSError *error))completion;

+ (void) searchFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
          searchcrit:(NSString *)searchcrit offset:(opt NSUInteger)offset maxcount:(opt NSUInteger)maxcount
          showhidden:(opt BOOL)showhidden sortcrit:(opt NSString *)sortcrit
          completion:(void(^)(NSDictionary *response, NSError *error))completion;

+ (void)  createFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
            filename:(NSString *)filename parentid:(opt NSString *)parentid type:(opt NSString *)type
               mtime:(opt NSDate *)mtime ctime:(opt NSDate *)ctime
          completion:(void(^)(NSDictionary *response, NSError *error))completion;

+ (void)  removeFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(NSString *)fileid recurse:(opt BOOL)recurse
          completion:(void(^)(NSError *error))completion;

+ (void)    moveFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(NSString *)fileid newname:(opt NSString *)newname
          completion:(void(^)(NSError *error))completion;

+ (void) enableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(NSString *)fileid name:(opt NSString *)name password:(opt NSString *)password permissions:(opt NSString *)permissions
          completion:(void(^)(NSDictionary *response, NSError *error))completion;

+ (void)disableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(NSString *)fileid
          completion:(void(^)(NSError *error))completion;

+ (void)   sendShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(NSString *)fileid emails:(NSArray *)emails
          completion:(void(^)(NSError *error))completion;

+ (void)  listShares:(NSURL *)apiurl valtoken:(NSString *)valtoken
            deviceid:(opt NSString *)deviceid serviceid:(opt NSString *)serviceid
          completion:(void(^)(NSDictionary *response, NSError *error))completion;

#pragma mark utils

+ (void)  uploadFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(NSString *)fileid data:(NSData *)data
          completion:(void(^)(NSError *error))completion;

+ (void)downloadFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
              fileid:(NSString *)fileid
          completion:(void(^)(NSData *data, NSError *error))completion;

+ (NSError *)getFileURL:(NSURL *)svcurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                 fileid:(NSString *)fileid flag:(opt NSString *)flag name:(opt NSString *)name fileurl:(out NSURL **)fileurl;

+ (NSDate *)dateWithString:(NSString *)string;

@end
