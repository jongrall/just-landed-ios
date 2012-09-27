//
//  JLMailComposeViewController.m
//  Just Landed
//
//  Created by Jon Grall on 5/5/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMailComposeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface JLMailComposeViewController ()

- (BOOL)setMFMailFieldAsFirstResponder:(UIView *)view mfMailField:(NSString *)field;

@end


@implementation JLMailComposeViewController

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


- (void)setMFMailFieldAsFirstResponder {
    [self setMFMailFieldAsFirstResponder:self.view mfMailField:@"MFComposeTextContentView"];
}

//Returns true if the ToAddress field was found any of the sub views and made first responder
//passing in @"MFComposeSubjectView"     as the value for field makes the subject become first responder
//passing in @"MFComposeTextContentView" as the value for field makes the body become first responder
//passing in @"RecipientTextField"       as the value for field makes the to address field become first responder
- (BOOL)setMFMailFieldAsFirstResponder:(UIView *)view mfMailField:(NSString *)field {
    for (UIView *subview in view.subviews) {
        NSString *className = [NSString stringWithFormat:@"%@", [subview class]];
        NSLog(@"%@", subview);
        if ([className isEqualToString:field]) {
            //Found the sub view we need to set as first responder
            [subview becomeFirstResponder];
            return YES;
        }
        
        if ([subview.subviews count] > 0) {
            if ([self setMFMailFieldAsFirstResponder:subview mfMailField:field]){
                //Field was found and made first responder in a subview
                return YES;
            }
        }
    }
    
    //field not found in this view.
    return NO;
}

@end
