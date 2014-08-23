//
//  AccountParameters.h
//  NewCore
//
//  Created by Yang Jason on 14-8-23.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountParameters : NSObject
@property (nonatomic) NSURL    *baseurl;
@property (nonatomic) NSString *username; // an email.
@property (nonatomic) NSString *authorization;
@end
