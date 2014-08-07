//
//  Database.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseScheme : NSObject
@property (nonatomic,readonly) NSUInteger buildNumber;
@property (nonatomic,readonly) NSURL *storeURL;
@property (nonatomic,readonly) NSURL *modelURL;
- (id)initWithBuildNumber:(NSUInteger)buildNumber storeName:(NSString *)storeName modelName:(NSString *)modelName;
@end

@interface Database : NSObject
@property (nonatomic,readonly) NSManagedObjectContext *context;
@property (readonly) NSArray *allSchemes;
- (NSError *)upgrade:(DatabaseScheme *)from to:(DatabaseScheme *)to;
@end
