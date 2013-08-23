//
//  JLViewController.m
//  JustLanded
//
//  Created by Jon Grall on 8/21/13.
//  Copyright (c) 2013 Little Details LLC. All rights reserved.
//

#import "JLViewController.h"

@implementation JLViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

@end
