//
//  BackupFile.h
//  NewCore
//
//  Created by Jason Yang on 14-8-7.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BackupFile : NSManagedObject

@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) NSNumber * mediaType;
@property (nonatomic, retain) NSNumber * uploadedSize;
@property (nonatomic, retain) NSNumber * backupState;

@end
