//
//  Database.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Database : NSObject

@property (nonatomic,readonly) NSManagedObjectContext *context;

+ (Database *)database;

@end
