//
//  StorageFile.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-21.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "StorageFile.h"

@implementation StorageFile
@end

@implementation StorageMutableFile
#pragma mark - basic requied
@dynamic fileid;
@dynamic parentid;
@dynamic ownerid;
@dynamic type;
@dynamic name;
@dynamic ctime;
@dynamic mtime;
@dynamic size;
#pragma mark - normal optional
@dynamic mediatype;
@dynamic mimetype;
@dynamic longitude;
@dynamic latitude;
@dynamic origtime;
@dynamic thumbnail;
@dynamic preview;
@dynamic stream;
@dynamic streamtype;
#pragma mark - extra optional
@dynamic origin;
@dynamic originid;
@dynamic title;
@dynamic artist;
@dynamic album;
@dynamic genre;
@dynamic originalTrackNumber;
@dynamic exifMake;
@dynamic exifModel;
@dynamic linkref;
#pragma mark - collection only
@dynamic total;
@dynamic offset;
@dynamic lastRefreshDate;
@end
