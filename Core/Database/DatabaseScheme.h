//
//  DatabaseScheme.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseScheme : NSObject

@property (nonatomic,readonly) NSUInteger buildNumber; // app build number
@property (nonatomic,readonly) NSString *storeName; // database store name => store URL
@property (nonatomic,readonly) NSString *modelName; // database model name => model URL

@property (nonatomic,readonly,weak) id upgrader;
@property (nonatomic,readonly) SEL selector;

@property (nonatomic,readonly) NSURL *storeURL;
@property (nonatomic,readonly) NSURL *modelURL;

- (id)initWithBuildNumber:(NSUInteger)buildNumber storeName:(NSString *)storeName modelName:(NSString *)modelName upgrader:(id)upgrader selector:(SEL)selector;

@end
