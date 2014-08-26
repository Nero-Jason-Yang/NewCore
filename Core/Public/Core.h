//
//  CoreAPI.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "Error.h"
#import "File.h"
#import "Operation.h"

@interface Core : NSObject

+ (Core *)sharedInstance;

@property (nonatomic,readonly) AccountState accountState;

#pragma mark - account actions

- (Operation *)login:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion;
- (Operation *)logout:(void(^)(NSError *error))completion;
- (void)logout;
- (Operation *)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(void(^)(NSError *error))completion;
- (Operation *)forgotPassword:(NSString *)email completion:(void(^)(NSError *error))completion;
- (Operation *)acceptTOS:(NSString *)email completion:(void(^)(NSError *error))completion;

#pragma mark - file actions

// open a file with name, if not found then create it.
- (Operation *)openFile:(NSString *)filename parentid:(NSString *)parentid type:(FileType)type ctime:(NSDate *)ctime mtime:(NSDate *)mtime completion:(void(^)(File *file, NSError *error))completion;
- (Operation *)renameFile:(NSString *)fileid newname:(NSString *)newname completion:(void(^)(NSError *error))completion;
- (Operation *)deleteFile:(NSString *)fileid recurse:(BOOL)recurse completion:(void(^)(NSError *error))completion;
- (Operation *)uploadFile:(NSString *)fileid data:(NSData *)data completion:(void(^)(NSError *error))completion;
- (Operation *)downloadFile:(NSString *)fileid completion:(void(^)(NSData *data, NSError *error))completion;

// to retrieve file URL.
- (Operation *)getThumbnailURL:(File *)file completion:(void(^)(NSURL *url, NSError *error))completion;
- (Operation *)getPreviewURL:(File *)file completion:(void(^)(NSURL *url, NSError *error))completion;
- (Operation *)getStreamURL:(File *)file completion:(void(^)(NSURL *url, NSError *error))completion;

// to retrieve file cache-key.
- (NSError *)forFile:(File *)file getThumbnailCacheKey:(NSString **)key;
- (NSError *)forFile:(File *)file getPreviewCacheKey:(NSString **)key;
- (NSError *)forFile:(File *)file getOriginCacheKey:(NSString **)key;

#pragma mark - collection actions

// various kinds of root collections.
@property (nonatomic,readonly) File *root;
@property (nonatomic,readonly) File *photoTimelines;
@property (nonatomic,readonly) File *photoAlbums;
@property (nonatomic,readonly) File *videoTimelines;
@property (nonatomic,readonly) File *videoAlbums;
@property (nonatomic,readonly) File *documents;
@property (nonatomic,readonly) File *musicSongs;
@property (nonatomic,readonly) File *musicAlbums;
@property (nonatomic,readonly) File *musicArtists;
@property (nonatomic,readonly) File *musicGenres;
@property (nonatomic,readonly) File *musicPlaylists;
@property (nonatomic,readonly) File *genericCollections; // a generic collection is a group of files, used for multi-share.

// list children.
- (NSError *)forCollection:(File *)collection getCachedFiles:(NSArray/*<File>*/**)files;
- (NSError *)forCollection:(File *)collection refresh:(NSUInteger)size getFiles:(NSArray/*<File>*/**)files;
- (NSError *)forCollection:(File *)collection next:(NSUInteger)size getFiles:(NSArray/*<File>*/**)files;

// create custom collection.
- (NSError *)openPhotoAlbum:(NSString *)name album:(File **)album;
- (NSError *)openMusicPlaylist:(NSString *)name playlist:(File **)playlist;
- (NSError *)openGenericCollection:(NSString *)name collection:(File **)collection;

// add file to custom collection.
- (NSError *)forPhotoAlbum:(File *)album addFile:(File **)file getItem:(File **)item;
- (NSError *)forMusicPlaylist:(File *)playlist addFile:(File **)file getItem:(File **)item;
- (NSError *)forGenericCollection:(File *)collection addFile:(File **)file getItem:(File **)item;

#pragma mark - share actions

- (NSError *)shareFile:(NSString *)fileid shareURL:(NSURL **)shareURL;

@end


