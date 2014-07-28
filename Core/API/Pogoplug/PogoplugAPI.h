//
//  PogoplugAPI.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define opt // optional parameter indicator

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

@interface PogoplugAPI : NSObject

+ (NSDate *)dateWithString:(NSString *)string;

+ (NSError *) listDevices:(NSURL *)apiurl valtoken:(NSString *)valtoken
                   result:(out NSDictionary **)result;
+ (NSError *)     getFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                   fileid:(opt NSString *)fileid filename:(opt NSString *)filename parentid:(opt NSString *)parentid
                   result:(out NSDictionary **)result;
+ (NSError *)   listFiles:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                 parentid:(NSString *)parentid offset:(opt NSUInteger)offset maxcount:(opt NSUInteger)maxcount showhidden:(opt BOOL)showhidden sortcrit:(opt NSString *)sortcrit filtercrit:(opt NSString *)filtercrit
                   result:(out NSDictionary **)result;
+ (NSError *)  createFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                 filename:(NSString *)filename parentid:(opt NSString *)parentid type:(opt NSString *)type mtime:(opt NSDate *)mtime ctime:(opt NSDate *)ctime
                   result:(out NSDictionary **)result;
+ (NSError *)  removeFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                   fileid:(NSString *)fileid recurse:(opt BOOL)recurse;
+ (NSError *)    moveFile:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                   fileid:(NSString *)fileid newname:(opt NSString *)newname;
+ (NSError *) enableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                   fileid:(NSString *)fileid name:(opt NSString *)name password:(opt NSString *)password permissions:(opt NSString *)permissions
                   result:(out NSDictionary **)result;
+ (NSError *)disableShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                   fileid:(NSString *)fileid;
+ (NSError *)   sendShare:(NSURL *)apiurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                   fileid:(NSString *)fileid emails:(NSArray *)emails;
+ (NSError *)  listShares:(NSURL *)apiurl valtoken:(NSString *)valtoken
                 deviceid:(opt NSString *)deviceid serviceid:(opt NSString *)serviceid
                   result:(out NSDictionary **)result;

+ (NSError *)  getFileURL:(NSURL *)svcurl valtoken:(NSString *)valtoken deviceid:(NSString *)deviceid serviceid:(NSString *)serviceid
                   fileid:(NSString *)fileid flag:(opt NSString *)flag name:(opt NSString *)name
                   result:(out NSURL **)result;
@end
