//
//  NSManagedObjectContext+Utils.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Utils)

+ (NSManagedObjectContext *)contextWithName:(NSString *)name;

@end
