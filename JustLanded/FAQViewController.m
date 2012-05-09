//
//  TOSViewController.m
//  SimplyListed
//
//  Created by Jon Grall on 3/25/11.
//  Copyright 2011 Friendfer. All rights reserved.
//

#import "FAQViewController.h"
#import "AFHTTPRequestOperation.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface FAQViewController () {
    __strong JLLoadingView *_loadingOverlay;
    __strong JLNoConnectionView *_noConnectionOverlay;
    __strong JLServerErrorView *_serverErrorOverlay;
}

- (void)startLoading;
- (void)stopLoading;
- (void)loadFAQ;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FAQViewController

@synthesize faqWebView;

- (void)loadFAQ {
    NSURL *faqURL = [NSURL URLWithString:[WEB_HOST stringByAppendingString:FAQ_PATH]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:faqURL];
    [req setTimeoutInterval:15.0];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:WEB_HOST]];
    operation.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 2)];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.0]; // Delay prevents white flash as webview loads content
        NSString *responseString = [operation responseString];
        [faqWebView setHidden:NO];
        [faqWebView loadHTMLString:responseString baseURL:[NSURL URLWithString:WEB_HOST]];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                                         [self stopLoading];
                                         NSHTTPURLResponse *response = [operation response];
                                         
                                         if (!_serverErrorOverlay) {
                                             _serverErrorOverlay = [[JLServerErrorView alloc] initWithFrame:self.view.bounds 
                                                                                                  errorType:ERROR_500];
                                             _serverErrorOverlay.delegate = self;
                                         }
                                         
                                         if (response) {
                                             switch ([response statusCode]) {
                                                 case 503: {
                                                     _serverErrorOverlay.errorType = ERROR_503;
                                                     break;
                                                 }
                                                 default: {
                                                     _serverErrorOverlay.errorType = ERROR_500;
                                                     break;
                                                 }
                                             }
                                             
                                             _serverErrorOverlay.tryAgainbutton.enabled = YES;
                                             [self.view addSubview:_serverErrorOverlay];
                                         }
                                         else {
                                             // Handle no connection
                                             if (!_noConnectionOverlay) {
                                                 _noConnectionOverlay = [[JLNoConnectionView alloc] initWithFrame:self.view.bounds];
                                                 _noConnectionOverlay.delegate = self;
                                             }
                                             
                                             _noConnectionOverlay.tryAgainbutton.enabled = YES;
                                             [self.view addSubview:_noConnectionOverlay];
                                         }
                                     }];
    
    [self startLoading];
    [client enqueueHTTPRequestOperation:operation];
}


- (void)startLoading {
    [_noConnectionOverlay removeFromSuperview];
    [_serverErrorOverlay removeFromSuperview];
    [faqWebView setHidden:YES];
    
    if (!_loadingOverlay) {
        _loadingOverlay = [[JLLoadingView alloc] initWithFrame:self.view.bounds];
    }
    
    [self.view addSubview:_loadingOverlay];
    [_loadingOverlay startLoading];
}


- (void)stopLoading {
    [_loadingOverlay stopLoading];
    [_loadingOverlay removeFromSuperview];
}


- (void)tryConnectionAgain {
    [self loadFAQ];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    mainView.backgroundColor = [UIColor clearColor];
    self.view = mainView;
    
	self.faqWebView = [[JLWebView alloc] initWithFrame:self.view.bounds];
	self.faqWebView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
    self.faqWebView.backgroundColor = [UIColor clearColor];
    faqWebView.hidden = YES;
	[self.view addSubview:faqWebView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
	
	//Load the TOS from the web
	[self loadFAQ];
}


- (void)viewDidUnload {
	self.faqWebView.delegate = nil;
	self.faqWebView = nil;
	[super viewDidUnload];
}

@end
