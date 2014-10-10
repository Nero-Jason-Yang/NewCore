//
//  UIView+Log.m
//  NewCore
//
//  Created by Jason Yang on 14-10-10.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "UIView+Log.h"

@implementation UIView (Log)

- (void)logSubviews
{
    NSString *name = [NSString stringWithFormat:@"[%@]", NSStringFromClass(self.class)];
    NSMutableArray *components = [NSMutableArray arrayWithObject:name];
    for (UIView *superview = self.superview; superview; superview = superview.superview) {
        [components insertObject:NSStringFromClass(superview.class) atIndex:0];
    }
    NSString *path = [components componentsJoinedByString:@"."];
    [self logSubviewsWithPath:path];
}

- (void)logSubviewsWithPath:(NSString *)path
{
    for (UIView *subview in self.subviews) {
        NSString *subpath = [path stringByAppendingFormat:@".%@", NSStringFromClass(subview.class)];
        NSLog(@"%@", subpath);
        [subview logSubviewsWithPath:subpath];
    }
}

@end
