//
//  NSBundle+Utils.h
//  NewCore
//
//  Created by Jason Yang on 14-8-4.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Utils)

- (NSString *)bundleVersion;      // e.g.  "1.0.2.34"
- (NSString *)bundleVersionShort; // e.g.  "1.0.2"
- (NSUInteger)buildNumber;         // e.g.  34

@end
