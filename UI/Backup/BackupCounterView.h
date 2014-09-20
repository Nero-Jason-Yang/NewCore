//
//  BackupCounterView.h
//  NewCore
//
//  Created by Yang Jason on 14-9-20.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackupCounterView : UIView
@property (nonatomic) NSUInteger countOfPhotos;
@property (nonatomic) NSUInteger countOfVideos;
@end

@interface BackupCounterCell : UIView
@property (nonatomic) NSInteger count;
@property (nonatomic) NSString *title;
@end
