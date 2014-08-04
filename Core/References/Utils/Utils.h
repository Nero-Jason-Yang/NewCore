//
//  Utils.h
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define opt // optional parameter indicator

#import "NSBundle+Utils.h"
#import "NSError+HTTP.h"
#import "NSManagedObjectContext+Utils.h"
#import "NSURL+Utils.h"

#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    code                                                                \
    _Pragma("clang diagnostic pop")                                     \