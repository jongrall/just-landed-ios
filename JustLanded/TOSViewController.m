//
//  TOSViewController.m
//
//  Created by Jon Grall on 5/23/12.
//  Copyright 2012 Little Details LLC. All rights reserved.
//

#import "TOSViewController.h"
#import "AFHTTPRequestOperation.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface TOSViewController () {
    __strong JLLoadingView *_loadingOverlay;
    __strong JLNoConnectionView *_noConnectionOverlay;
    __strong JLServerErrorView *_serverErrorOverlay;
}

- (void)startLoading;
- (void)stopLoading;
- (void)loadTOS;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation TOSViewController

@synthesize tosWebView;

- (void)loadTOS {
    NSURL *tosURL = [NSURL URLWithString:[WEB_HOST stringByAppendingString:TOS_PATH]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:tosURL];
    [req setTimeoutInterval:15.0];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:WEB_HOST]];
    operation.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 2)];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.0]; // Delay prevents white flash as webview loads content
        NSString *responseString = [operation responseString];
        [tosWebView setHidden:NO];
        [tosWebView loadHTMLString:responseString baseURL:[NSURL URLWithString:WEB_HOST]];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                                         [self stopLoading];
                                         NSHTTPURLResponse *response = [operation response];
                                         
                                         if (!_serverErrorOverlay) {
                                             _serverErrorOverlay = [[JLServerErrorView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                                       0.0f,
                                                                                                                       320.0f,
                                                                                                                       460.0f) 
                                                                                                  errorType:ERROR_500];
                                             _serverErrorOverlay.frame = CGRectMake(0.0f,
                                                                                    -44.0f,
                                                                                    320.0f,
                                                                                    460.0f);
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
                                                 _noConnectionOverlay = [[JLNoConnectionView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                                             0.0f,
                                                                                                                             320.0f,
                                                                                                                             460.0f)];
                                                 _noConnectionOverlay.frame = CGRectMake(0.0f,
                                                                                        -44.0f,
                                                                                        320.0f,
                                                                                        460.0f);
                                                 _noConnectionOverlay.noConnectionImageView.frame = CGRectMake(_noConnectionOverlay.noConnectionImageView.frame.origin.x,
                                                                                                               70.0f,
                                                                                                               _noConnectionOverlay.noConnectionImageView.frame.size.width,
                                                                                                               _noConnectionOverlay.noConnectionImageView.frame.size.height);
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
    [tosWebView setHidden:YES];
    
    if (!_loadingOverlay) {
        _loadingOverlay = [[JLLoadingView alloc] initWithFrame:CGRectMake(0.0f,
                                                                          0.0f,
                                                                          320.0f,
                                                                          460.0f)];
        _loadingOverlay.frame = CGRectMake(0.0f,
                                           -44.0f,
                                           320.0f,
                                           460.0f);
    }
    
    [self.view addSubview:_loadingOverlay];
    [_loadingOverlay startLoading];
}


- (void)stopLoading {
    [_loadingOverlay stopLoading];
    [_loadingOverlay removeFromSuperview];
}


- (void)tryConnectionAgain {
    [self loadTOS];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    mainView.backgroundColor = [UIColor colorWithRed:231/255.0f green:228/255.0f blue:223.0f/255.0f alpha:1.0f];
    self.view = mainView;
    
    // Add a black BG
    UIView *blackBG = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 200.0f, 320.0f, 216.0f)];
    blackBG.backgroundColor = [UIColor blackColor];
    
	self.tosWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    self.tosWebView.scrollView.alwaysBounceVertical = NO;
    self.tosWebView.scrollView.alwaysBounceHorizontal = NO;
    self.tosWebView.scrollView.bounces = NO;
	self.tosWebView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.tosWebView.backgroundColor = [UIColor clearColor];
    self.tosWebView.layer.cornerRadius = 6.0f;
    self.tosWebView.clipsToBounds = YES;
    self.tosWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tosWebView.hidden = YES;
    [self.view addSubview:blackBG];
	[self.view addSubview:tosWebView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Terms of Service", @"Terms of Service.");
	
	//Load the TOS from the web
	[self loadTOS];
}


- (void)viewDidUnload {
    [super viewDidUnload];
	self.tosWebView = nil;
    _noConnectionOverlay = nil;
    _serverErrorOverlay = nil;
}


- (void)dealloc {
    tosWebView.delegate = nil;
    _noConnectionOverlay.delegate = nil;
    _serverErrorOverlay.delegate = nil;
}

@end
