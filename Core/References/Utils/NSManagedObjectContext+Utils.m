//
//  NSManagedObjectContext+Utils.m
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "NSManagedObjectContext+Utils.h"

@implementation NSManagedObjectContext (Utils)

+ (NSManagedObjectContext *)contextWithName:(NSString *)name
{
    NSURL *docURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [docURL URLByAppendingPathComponent:[name stringByAppendingPathExtension:@"sqlite"]];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"momd"];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSError *error = nil;
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES],
                              NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]
                              };
    
    if (![store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, at file:%s(%d)", error, __FILE__, __LINE__);
        abort();
    }
    if (![storeURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error]) {
        NSLog(@"Unresolved error %@, at file:%s(%d)", error, __FILE__, __LINE__);
        abort();
    }
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setPersistentStoreCoordinator:store];
    return context;
}

@end
