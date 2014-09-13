//
//  SkinScheme.h
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkinScheme : NSObject
+ (SkinScheme *)currentSkinScheme;
@property (nonatomic) UIColor *navBarBackgroundColor;
@property (nonatomic) UIColor *navBarForegroundColor;
@property (nonatomic) UIColor *tabBarBackgroundColor;
@property (nonatomic) UIColor *tabBarForegroundColor;
@end
