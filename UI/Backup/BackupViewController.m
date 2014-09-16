//
//  BackupViewController.m
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupViewController.h"
#import "TabBarController.h"
#import "BackupButtonView.h"
#import "Common.h"

CGRect CGRectMakeAtBottomWithHeight(CGRect rect, CGFloat height)
{
    if (rect.size.height >= height) {
        rect.origin.y = rect.origin.y + rect.size.height - height;
        rect.size.height = height;
        return rect;
    }
    else {
        return CGRectZero;
    }
}

@interface BackupViewController ()
@property (nonatomic) BackupButtonView *buttonView;
@property (nonatomic) UILabel *messageView;
@property (nonatomic) UIView *counterView;
@end

@implementation BackupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButtonPress:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView topLogoView]];
    self.navigationController.navigationBar.barTintColor = [SkinScheme currentSkinScheme].navBarBackgroundColor;
    self.navigationController.navigationBar.tintColor = [SkinScheme currentSkinScheme].navBarForegroundColor;
    
    self.heightOfMessageView = 40;
    self.heightOfCounterView = 60;
    self.buttonView = [[BackupButtonView alloc] init];
    self.buttonView.margin = 0.2;
    [self.view addSubview:self.buttonView];
    self.messageView = [[UILabel alloc] init];
    [self.view addSubview:self.messageView];
    self.counterView = [[UIView alloc] init];
    [self.view addSubview:self.counterView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // calculate frames
    CGRect remainFrame = self.view.frame;
    remainFrame.origin = CGPointZero;
    CGRect counterViewFrame = CGRectMakeAtBottomWithHeight(remainFrame, self.heightOfCounterView);
    remainFrame.size.height -= self.heightOfCounterView;
    CGRect messageViewFrame = CGRectMakeAtBottomWithHeight(remainFrame, self.heightOfMessageView);
    remainFrame.size.height -= self.heightOfMessageView;
    CGRect buttonViewFrame = remainFrame;
    
    // set frames
    self.buttonView.frame = buttonViewFrame;
    self.messageView.frame = messageViewFrame;
    self.counterView.frame = counterViewFrame;
    
    // set background colors
    self.buttonView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.messageView.backgroundColor = [UIColor lightGrayColor];
    self.counterView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRightButtonPress:(id)sender
{
    TabBarController *vc = [[TabBarController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
