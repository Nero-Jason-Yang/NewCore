//
//  CoreAPI.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StorageFile.h"

#define AccountNeedLoginNotification @"AccountNeedLoginNotification"

typedef enum : uint8_t {
    AccountState_Unknown = 0,
    AccountState_Logouted,
    AccountState_Logining,
    AccountState_LoginSucceeded,
    AccountState_LoginFailed,
    AccountState_Unauthorized,
} AccountState;

@interface CoreAPI : NSObject

+ (CoreAPI *)sharedInstance;

@property (nonatomic,readonly) AccountState accountState;
/*
@property (nonatomic,readonly) NSURL *accountApiUrl;

@property (nonatomic,readonly) NSURL *storageApiUrl; // pogoplug subscription api url.
@property (nonatomic,readonly) NSString *pogoplugDeviceID;
@property (nonatomic,readonly) NSString *pogoplugServiceID;
@property (nonatomic,readonly) NSURL *pogoplugServiceApiUrl; // pogoplug service api url.
*/

#pragma mark - account actions

- (NSError *)login:(NSString *)username password:(NSString *)password;
- (NSError *)logout;
- (NSError *)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword;
- (NSError *)forgotPassword:(NSString *)email;
- (NSError *)acceptTOS:(NSString *)email;

#pragma mark - file actions

// open a file with name, if not found then create it.
- (NSError *)openFile:(NSString *)filename parentid:(NSString *)parentid type:(FileType)type ctime:(NSDate *)ctime mtime:(NSDate *)mtime file:(StorageFile **)file;
- (NSError *)renameFile:(NSString *)fileid newname:(NSString *)newname;
- (NSError *)deleteFile:(NSString *)fileid recurse:(BOOL)recurse;
- (NSError *)uploadFile:(NSString *)fileid data:(NSData *)data;
- (NSError *)downloadFile:(NSString *)fileid data:(NSData **)data;

// to retrieve file URL.
- (NSError *)forFile:(StorageFile *)file getThumbnailURL:(NSURL **)URL;
- (NSError *)forFile:(StorageFile *)file getPreviewURL:(NSURL **)URL;
- (NSError *)forFile:(StorageFile *)file getStreamURL:(NSURL **)URL;

// to retrieve file cache-key.
- (NSError *)forFile:(StorageFile *)file getThumbnailCacheKey:(NSString **)key;
- (NSError *)forFile:(StorageFile *)file getPreviewCacheKey:(NSString **)key;
- (NSError *)forFile:(StorageFile *)file getOriginCacheKey:(NSString **)key;

#pragma mark - collection actions

// various kinds of root collections.
@property (nonatomic,readonly) StorageFile *root;
@property (nonatomic,readonly) StorageFile *photoTimelines;
@property (nonatomic,readonly) StorageFile *photoAlbums;
@property (nonatomic,readonly) StorageFile *videoTimelines;
@property (nonatomic,readonly) StorageFile *videoAlbums;
@property (nonatomic,readonly) StorageFile *documents;
@property (nonatomic,readonly) StorageFile *musicSongs;
@property (nonatomic,readonly) StorageFile *musicAlbums;
@property (nonatomic,readonly) StorageFile *musicArtists;
@property (nonatomic,readonly) StorageFile *musicGenres;
@property (nonatomic,readonly) StorageFile *musicPlaylists;
@property (nonatomic,readonly) StorageFile *genericCollections; // a generic collection is a group of files, used for multi-share.

// list children.
- (NSError *)forCollection:(StorageFile *)collection getCachedFiles:(NSArray/*<StorageFile>*/**)files;
- (NSError *)forCollection:(StorageFile *)collection refresh:(NSUInteger)size getFiles:(NSArray/*<StorageFile>*/**)files;
- (NSError *)forCollection:(StorageFile *)collection next:(NSUInteger)size getFiles:(NSArray/*<StorageFile>*/**)files;

// create custom collection.
- (NSError *)openPhotoAlbum:(NSString *)name album:(StorageFile **)album;
- (NSError *)openMusicPlaylist:(NSString *)name playlist:(StorageFile **)playlist;
- (NSError *)openGenericCollection:(NSString *)name collection:(StorageFile **)collection;

// add file to custom collection.
- (NSError *)forPhotoAlbum:(StorageFile *)album addFile:(StorageFile **)file getItem:(StorageFile **)item;
- (NSError *)forMusicPlaylist:(StorageFile *)playlist addFile:(StorageFile **)file getItem:(StorageFile **)item;
- (NSError *)forGenericCollection:(StorageFile *)collection addFile:(StorageFile **)file getItem:(StorageFile **)item;

#pragma mark - share actions

- (NSError *)shareFile:(NSString *)fileid shareURL:(NSURL **)shareURL;

@end
