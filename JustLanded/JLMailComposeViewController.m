//
//  JLMailComposeViewController.m
//  JustLanded
//
//  Created by Jon Grall on 5/5/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMailComposeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface JLMailComposeViewController ()

@end

@implementation JLMailComposeViewController

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
    
    self.navigationBar.tintColor = [UIColor colorWithRed:248.0f/255.0f green:153.0f/255.0f blue:0.0f alpha:1.0f];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
