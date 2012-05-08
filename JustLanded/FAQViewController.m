//
//  TOSViewController.m
//  SimplyListed
//
//  Created by Jon Grall on 3/25/11.
//  Copyright 2011 Friendfer. All rights reserved.
//

#import "FAQViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface FAQViewController ()

@property (nonatomic, retain) UIView *loadingScreen_;

- (void)displayLoadingScreen;
- (void)removeLoadingScreen;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FAQViewController

@synthesize faqWebView;
@synthesize loadingScreen_;


- (void)loadView {
	self.faqWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
	self.faqWebView.delegate = self;
	self.faqWebView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
	self.view = faqWebView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
	
	//Load the TOS from the web
	[self displayLoadingScreen];
	[self.faqWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:FAQ_URL]]];
}


- (void)displayLoadingScreen {
    // Implement me
}


- (void)removeLoadingScreen {
	[loadingScreen_ removeFromSuperview];
	self.loadingScreen_ = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebViewDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void) webViewDidFinishLoad:(UIWebView *)webView {
	[self removeLoadingScreen];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self removeLoadingScreen];
    
    // TODO: show no connection screen
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload {
	self.faqWebView.delegate = nil;
	self.faqWebView = nil;
	self.loadingScreen_ = nil;
	[super viewDidUnload];
}

@end
