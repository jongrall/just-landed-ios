//
//  JLMessageComposeViewController.m
//  JustLanded
//
//  Created by Jon on 9/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import QuartzCore;
#import "JLMessageComposeViewController.h"

@implementation JLMessageComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Customize the navbar
    self.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationBar.layer.shadowOpacity = 0.5f;
    self.navigationBar.layer.shadowRadius = 0.25f;
    self.navigationBar.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self.navigationController.navigationBar bounds]] CGPath]; //Optimization avoids offscreen render pass
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
