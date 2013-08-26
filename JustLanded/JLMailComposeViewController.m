//
//  JLMailComposeViewController.m
//  Just Landed
//
//  Created by Jon Grall on 5/5/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMailComposeViewController.h"

@interface JLMailComposeViewController ()

- (BOOL)setMFMailFieldAsFirstResponder:(UIView *)view mfMailField:(NSString *)field;

@end


@implementation JLMailComposeViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (iOS_6_OrEarlier()) {
        [self.navigationBar adoptJustLandedStyle];
        [self.topViewController.navigationItem.leftBarButtonItem adoptJustLandedStyle];
        [self.topViewController.navigationItem.rightBarButtonItem adoptJustLandedStyle];
    }
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
