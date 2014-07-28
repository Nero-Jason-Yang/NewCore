//
//  StorageFile+Pogoplug.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-21.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "StorageFile+Pogoplug.h"

@implementation StorageFile (Pogoplug)

+ (NSError *)makeFile:(StorageFile **)file fromPogoplugResponse:(PogoplugResponse_File *)response
{
    NSParameterAssert(file && response);
    
    StorageMutableFile *mfile = [[StorageMutableFile alloc] init];
    mfile.fileid = response.fileID;
    mfile.parentid = response.parentID;
    mfile.ownerid = response.ownerID;
    mfile.type = (FileType)response.type.integerValue;
    mfile.name = response.name;
    mfile.ctime = response.ctime;
    mfile.mtime = response.mtime;
    mfile.size = response.size;
    
    mfile.mediatype = response.mediaType;
    mfile.mimetype = response.mimeType;
    mfile.longitude = response.longitude;
    mfile.latitude = response.latitude;
    mfile.origtime = response.origtime;
    mfile.thumbnail = response.thumbnail;
    mfile.preview = response.preview;
    mfile.stream = response.stream;
    mfile.streamtype = response.streamType;
    
    PogoplugResponse_FileProperties *properties = response.properties;
    if (properties) {
        mfile.origin = properties.origin;
        mfile.originid = properties.originID;
        mfile.title = properties.title;
        mfile.artist = properties.artist;
        mfile.album = properties.album;
        mfile.genre = properties.genre;
        mfile.originalTrackNumber = properties.originalTrackNumber;
        mfile.exifMake = properties.EXIFMake;
        mfile.exifModel = properties.EXIFModel;
        mfile.linkref = properties.linkref;
    }
    
    return nil;
}

@end
