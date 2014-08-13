//
//  Utils.h
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define opt // optional parameter indicator
#define _PerformSelectorBegin _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
#define _PerformSelectorEnd   _Pragma("clang diagnostic pop")

#define isstring(x) [x isKindOfClass:NSString.class]

#import "NSBundle+Utils.h"
#import "NSError+HTTP.h"
#import "NSManagedObjectContext+Utils.h"
#import "NSURL+Utils.h"
#import "Database.h"
