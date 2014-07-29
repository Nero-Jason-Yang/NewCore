//
//  StorageFile+Pogoplug.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-21.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "File.h"
#import "PogoplugResponse.h"

@interface File (Pogoplug)

+ (NSError *)makeFile:(File **)file fromPogoplugResponse:(PogoplugResponse_File *)response;

@end
