//
//  NSDate+Pogoplug.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Pogoplug)

+ (id)dateWithPogoplugTimeString:(NSString *)string;
- (NSString *)pogoplugTimeString;

@end
