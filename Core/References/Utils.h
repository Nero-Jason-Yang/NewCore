//
//  Utils.h
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define opt // optional parameter indicator

@interface Utils : NSObject

@end


@interface NSURL (Utils)
+ (NSURL *)URLWithPath:(NSString *)path relativeToURL:(NSURL *)url;
+ (NSURL *)URLWithScheme:(NSString *)scheme relativeToURL:(NSURL *)url;
@end

@interface NSDate (Pogoplug)
+ (id)dateWithPogoplugTimeString:(NSString *)string;
- (NSString *)pogoplugTimeString;
@end
