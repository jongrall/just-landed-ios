//
//  JLMessageComposeViewController.m
//  JustLanded
//
//  Created by Jon on 9/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMessageComposeViewController.h"

@implementation JLMessageComposeViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (iOS_6_OrEarlier()) {
        [self.navigationBar adoptJustLandedStyle];
        [self.topViewController.navigationItem.leftBarButtonItem adoptJustLandedStyle];
        [self.topViewController.navigationItem.rightBarButtonItem adoptJustLandedStyle];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!iOS_6_OrEarlier()) {
        for (UIWindow *aWindow in [UIApplication sharedApplication].windows) {
            aWindow.layer.masksToBounds = YES;
            aWindow.layer.cornerRadius = 6.0f;
        }
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
