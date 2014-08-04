//
//  NSURL+Utils.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Utils)

+ (NSURL *)URLWithPath:(NSString *)path relativeToURL:(NSURL *)url;
+ (NSURL *)URLWithScheme:(NSString *)scheme relativeToURL:(NSURL *)url;

@end
