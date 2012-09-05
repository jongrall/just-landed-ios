//
//  JLMessageComposeViewController.m
//  JustLanded
//
//  Created by Jon on 9/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMessageComposeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation JLMessageComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Customize the navbar
    self.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationBar.layer.shadowOpacity = 0.5f;
    self.navigationBar.layer.shadowRadius = 0.25f;
    self.navigationBar.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self.navigationController.navigationBar bounds]] CGPath]; //Optimization avoids offscreen render pass
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
