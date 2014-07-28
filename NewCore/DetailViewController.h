//
//  DetailViewController.h
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (weak, nonatomic) UITableViewCell *sourceCell;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
