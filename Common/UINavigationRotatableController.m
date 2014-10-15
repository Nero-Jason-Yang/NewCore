//
//  UINavigationRotatableController.m
//  ViewControllerRotation
//
//  Created by Jason Yang on 14-8-22.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "UINavigationRotatableController.h"

//
//
// UIDevice (Orientation)
//
//////////

@interface _UIMutableDevice : UIDevice
@property(nonatomic) UIDeviceOrientation orientation;
@end

@implementation _UIMutableDevice
@dynamic orientation;
@end

@interface UIDevice (Orientation)
@property UIInterfaceOrientation interfaceOrientation;
@end

@implementation UIDevice (Orientation)
- (UIInterfaceOrientation)interfaceOrientation {
    return (UIInterfaceOrientation)self.orientation;
}
- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    ((_UIMutableDevice *)self).orientation = (UIDeviceOrientation)interfaceOrientation;
}
@end

//
//
// UINavigationRotatableController
//
//////////

@interface UINavigationRotatableController () <UINavigationControllerDelegate>
@property (nonatomic) UIInterfaceOrientation currentOrientation;
@end

@implementation UINavigationRotatableController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.currentOrientation = [UIDevice currentDevice].interfaceOrientation;
}

#pragma mark UIViewController(UIViewControllerRotation)

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.currentOrientation = toInterfaceOrientation;
}

- (BOOL)shouldAutorotate
{
    UIInterfaceOrientation deviceOrientation = [UIDevice currentDevice].interfaceOrientation;
    if (deviceOrientation == self.currentOrientation) {
        return NO;
    }
    
    UIInterfaceOrientationMask deviceOrientationMask = (1 << deviceOrientation);
    if (0 == (self.topViewController.supportedInterfaceOrientations & deviceOrientationMask)) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.topViewController) {
        return self.topViewController.supportedInterfaceOrientations;
    }
    
    return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.topViewController) {
        return self.topViewController.preferredInterfaceOrientationForPresentation;
    }
    
    return [super preferredInterfaceOrientationForPresentation];
}

#pragma mark <UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIDevice *device = [UIDevice currentDevice];
    UIInterfaceOrientation deviceOrientation = device.interfaceOrientation;
    UIInterfaceOrientationMask deviceOrientationMask = (1 << deviceOrientation);
    
    if (0 == (viewController.supportedInterfaceOrientations & deviceOrientationMask)) {
        device.interfaceOrientation = viewController.preferredInterfaceOrientationForPresentation;
        [self.class attemptRotationToDeviceOrientation];
        device.interfaceOrientation = deviceOrientation;
    }
    else if (deviceOrientation != self.currentOrientation) {
        [self.class attemptRotationToDeviceOrientation];
    }
}

@end
