//
//  File.h
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject

@end

@interface UIImageView (File)

- (void)setThumbnailWithFile:(File *)file placeholderImage:(UIImage *)placeholder;

- (void)clearFadeinEffect;

+ (void)cacheRefreshThumbnailWithFile:(File *)file;

@end
