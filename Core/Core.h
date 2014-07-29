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

- (void)login:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *))completion;
- (void)logout:(void(^)(NSError *))completion;
- (void)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(void(^)(NSError *))completion;
- (void)forgotPassword:(NSString *)email completion:(void(^)(NSError *))completion;
- (void)acceptTOS:(NSString *)email completion:(void(^)(NSError *))completion;

#pragma mark - file actions

// open a file with name, if not found then create it.
- (void)openFile:(NSString *)filename parentid:(NSString *)parentid type:(FileType)type ctime:(NSDate *)ctime mtime:(NSDate *)mtime completion:(void(^)(StorageFile *, NSError *))completion;
- (void)renameFile:(NSString *)fileid newname:(NSString *)newname completion:(void(^)(NSError *error))completion;
- (void)deleteFile:(NSString *)fileid recurse:(BOOL)recurse completion:(void(^)(NSError *error))completion;
- (void)uploadFile:(NSString *)fileid data:(NSData *)data completion:(void(^)(NSError *error))completion;
- (void)downloadFile:(NSString *)fileid completion:(void(^)(NSData *data, NSError *error))completion;

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
