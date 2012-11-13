//
//  JLMailComposeViewController.h
//  Just Landed
//
//  Created by Jon Grall on 5/5/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface JLMailComposeViewController : MFMailComposeViewController

- (void)setMFMailFieldAsFirstResponder;

@end
