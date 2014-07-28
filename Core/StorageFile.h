//
//  StorageFile.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-21.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum FileType {
    FileType_Normal = 0,
    FileType_Directory = 1,
    FileType_SymbolicLink = 3,
    FileType_Search = 9,
    FileType_MusicAlbum = 10,
    FileType_MusicArtist = 11,
    FileType_MusicGenre = 12,
    FileType_MusicPlaylist = 13,
    FileType_PhotoTimeline = 20,
    FileType_PhotoAlbum = 21,
    FileType_PhotoFace = 22,
    FileType_VideoTimeline = 30,
    FileType_VideoAlbum = 31,
    FileType_GenericCollection = 101,
    FileType_OriginCollection = 102,
} FileType;

#define MediaType_Image @"image"
#define MediaType_Video @"video"
#define MediaType_Audio @"audio"

@interface StorageFile : NSObject

// Basic requied properties.
#pragma mark - basic requied

// Unique ID (opaque string) representing this file.
@property (nonatomic,readonly) NSString *fileid;

// fileid of parent object of this file.
@property (nonatomic,readonly) NSString *parentid;

// userid of user that owns this file.
@property (nonatomic,readonly) NSString *ownerid;

// file types: normal-file, directory, muaic-album/artist/genre/playlist, photo-timeline/album/face, video-timeline/album, ...
@property (nonatomic,readonly) FileType type;

// Name of this file object.
@property (nonatomic,readonly) NSString *name;

// Creation date of file object.
@property (nonatomic,readonly) NSDate   *ctime;

// Modification date of file object.
@property (nonatomic,readonly) NSDate   *mtime;

// Length in bytes of primary stream attached to this file. Nil for collection.
@property (nonatomic,readonly) NSNumber *size;      // NSNumber<long long>

// Normal optional properties.
#pragma mark - normal optional

// Media type of the object (if known). eg: "image", "video", "audio".
@property (nonatomic,readonly) NSString *mediatype;

// Mime type of primary stream attached to this file (if known).
@property (nonatomic,readonly) NSString *mimetype;

// Geographic longitude where this file was created (if known).
@property (nonatomic,readonly) NSNumber *longitude; // NSNumber<float>

// Geographic latitude where this file was created (if known).
@property (nonatomic,readonly) NSNumber *latitude;  // NSNumber<float>

// Original tie of the object this file represents (e.g. date of photo was taken).
@property (nonatomic,readonly) NSDate   *origtime;

// fileid of the "extra stream" that represents the thumbnail of this object.
@property (nonatomic,readonly) NSString *thumbnail;

// fileid of the "extra stream" that represents the image preview of this object.
@property (nonatomic,readonly) NSString *preview;

// fileid of the "extra stream" that represents the transcoded video of this object.
@property (nonatomic,readonly) NSString *stream;

// Indicates the type of stream associated with file.stream (if any). A value of "full" means that a full transcoding is available.
@property (nonatomic,readonly) NSString *streamtype;

// Extra optional properties, arbitrary additional key value pairs can be added.
#pragma mark - extra optional

// Origin of where this file came from (e.g. name of phone that uploaded the file).
@property (nonatomic,readonly) NSString *origin;

// Origin's unique ID of this file if it has one.
@property (nonatomic,readonly) NSString *originid;

// User friendly title of this object for presentation (if set).
@property (nonatomic,readonly) NSString *title;

// Name of artist that performed this file's content.
@property (nonatomic,readonly) NSString *artist;

// Name of music album this music track appeared on.
@property (nonatomic,readonly) NSString *album;

// Name of music genre this track belongs to.
@property (nonatomic,readonly) NSString *genre;

// String of form int/int tracking the track number this was on the original music album.
@property (nonatomic,readonly) NSString *originalTrackNumber;

// Make of camera that took the photo (if known).
@property (nonatomic,readonly) NSString *exifMake;

// Model of camera that took the photo (if known).
@property (nonatomic,readonly) NSString *exifModel;

// fileid that this file object link to.
@property (nonatomic,readonly) NSString *linkref;

// Properties for collection only.
#pragma mark - collection only

// Total number of children in the cloud, nil means unknown.
@property (nonatomic,readonly) NSNumber *total;  // NSNumber<NSUInteger>

// Next reading position, default is 0.
@property (nonatomic,readonly) NSNumber *offset; // NSNumber<NSUInteger>

// Last refresh date of this collection object.
@property (nonatomic,readonly) NSDate   *lastRefreshDate;

@end

@interface StorageMutableFile : StorageFile
#pragma mark - basic requied
@property (nonatomic) NSString *fileid;
@property (nonatomic) NSString *parentid;
@property (nonatomic) NSString *ownerid;
@property (nonatomic) FileType type;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate   *ctime;
@property (nonatomic) NSDate   *mtime;
@property (nonatomic) NSNumber *size;
#pragma mark - normal optional
@property (nonatomic) NSString *mediatype;
@property (nonatomic) NSString *mimetype;
@property (nonatomic) NSNumber *longitude;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSDate   *origtime;
@property (nonatomic) NSString *thumbnail;
@property (nonatomic) NSString *preview;
@property (nonatomic) NSString *stream;
@property (nonatomic) NSString *streamtype;
#pragma mark - extra optional
@property (nonatomic) NSString *origin;
@property (nonatomic) NSString *originid;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *album;
@property (nonatomic) NSString *genre;
@property (nonatomic) NSString *originalTrackNumber;
@property (nonatomic) NSString *exifMake;
@property (nonatomic) NSString *exifModel;
@property (nonatomic) NSString *linkref;
#pragma mark - collection only
@property (nonatomic) NSNumber *total;
@property (nonatomic) NSNumber *offset;
@property (nonatomic) NSDate   *lastRefreshDate;
@end
