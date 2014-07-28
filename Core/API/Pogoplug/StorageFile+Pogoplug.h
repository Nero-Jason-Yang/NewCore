//
//  StorageFile+Pogoplug.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-21.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "StorageFile.h"
#import "PogoplugResponse.h"

@interface StorageFile (Pogoplug)

+ (NSError *)makeFile:(StorageFile **)file fromPogoplugResponse:(PogoplugResponse_File *)response;

@end
