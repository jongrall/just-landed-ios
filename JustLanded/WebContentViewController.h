//
//  WebContentViewController.h
//  Just Landed
//
//  Created by Jon Grall on 3/25/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface WebContentViewController : UIViewController {

}

@property (strong, nonatomic) UIWebView *webView;

- (id)initWithContentTitle:(NSString *)aTitle URL:(NSURL *)aContentURL showDoneButton:(BOOL)flag;

@end
