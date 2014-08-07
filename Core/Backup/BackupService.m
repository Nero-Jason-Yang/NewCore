//
//  BackupService.m
//  NewCore
//
//  Created by Jason Yang on 14-8-7.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupService.h"

typedef enum : int16_t {
    BackupFile_Excluded  = 0,
    BackupFile_Ready     = 1,
    BackupFile_Completed = 2,
} BackupFileState;

typedef enum : int16_t {
    BackupFile_Image = 0,
    BackupFile_Video = 1,
    BackupFile_Music = 2,
} BackupFileType;

@implementation BackupService

@end
