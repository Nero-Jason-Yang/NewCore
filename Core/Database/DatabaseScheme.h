//
//  DatabaseScheme.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseScheme : NSObject

@property (nonatomic,readonly) NSUInteger buildNumber;
@property (nonatomic,readonly,weak) id upgrader;
@property (nonatomic,readonly) SEL selector;
@property (nonatomic,readonly) NSURL *modelURL;
@property (nonatomic,readonly) NSURL *storeURL;

- (id)initWithBuildNumber:(NSUInteger)buildNumber upgrader:(id)upgrader selector:(SEL)selector;

@end
