//
//  PogoplugParameters.h
//  NewCore
//
//  Created by Yang Jason on 14-8-23.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PogoplugParameters : NSObject
@property (nonatomic) NSLock   *locker;
@property (nonatomic) NSURL    *apiurl;    // api base url.
@property (nonatomic) NSString *valtoken;  // pogoplug access token.
@property (nonatomic) NSDate   *tokendate; // last refresh date for valtoken.
@property (nonatomic) NSURL    *svcurl;    // service base url.
@property (nonatomic) NSString *deviceid;
@property (nonatomic) NSString *serviceid;
- (void)reset:(PogoplugParameters *)params;
@end
