//
//  WebContentViewController.m
//  Just Landed
//
//  Created by Jon Grall on 3/25/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "WebContentViewController.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface WebContentViewController () <NoConnectionDelegate, UIWebViewDelegate>

@property (strong, nonatomic) NSString *_contentTitle;
@property (strong, nonatomic) NSURL *_contentURL;
@property (strong, nonatomic) JLLoadingView *_loadingOverlay;
@property (strong, nonatomic) JLNoConnectionView *_noConnectionOverlay;
@property (strong, nonatomic) JLServerErrorView *_serverErrorOverlay;

- (void)indicateLoading;
- (void)indicateStoppedLoading;
- (void)loadContent;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation WebContentViewController

@synthesize webView;
@synthesize _contentTitle;
@synthesize _contentURL;
@synthesize _loadingOverlay;
@synthesize _noConnectionOverlay;
@synthesize _serverErrorOverlay;


- (id)initWithContentTitle:(NSString *)aTitle URL:(NSURL *)aContentURL {
    self = [super init];
    
    if (self) {
        self._contentTitle = (aTitle) ? aTitle : @"Untitled";
        self._contentURL = (aContentURL) ? aContentURL : [NSURL URLWithString:@"about:blank"];
    }
    
    return self;
}

- (void)loadContent {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_contentURL];
    [req setTimeoutInterval:15.0];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    // Compute base URL
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", [_contentURL scheme], [_contentURL host]]];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    
    // Use iOS user agent string
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    [client setDefaultHeader:@"User-Agent" value:userAgent];
    
    operation.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 4)];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self performSelector:@selector(indicateStoppedLoading) withObject:nil afterDelay:1.0]; // Delay prevents white flash as webview loads content
        NSString *responseString = [operation responseString];
        [webView setHidden:NO];
        [webView loadHTMLString:responseString baseURL:[NSURL URLWithString:WEB_HOST]];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                                         [self indicateStoppedLoading];
                                         NSHTTPURLResponse *response = [operation response];
                                         
                                         if (!_serverErrorOverlay) {
                                             self._serverErrorOverlay = [[JLServerErrorView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                                       0.0f,
                                                                                                                       320.0f,
                                                                                                                       460.0f) 
                                                                                                       errorType:ERROR_500];
                                             self._serverErrorOverlay.frame = CGRectMake(0.0f,
                                                                                         -44.0f,
                                                                                         320.0f,
                                                                                         460.0f);
                                             self._serverErrorOverlay.delegate = self;
                                         }
                                         
                                         if (response) {
                                             switch ([response statusCode]) {
                                                 case 503: {
                                                     self._serverErrorOverlay.errorType = ERROR_503;
                                                     break;
                                                 }
                                                 default: {
                                                     self._serverErrorOverlay.errorType = ERROR_500;
                                                     break;
                                                 }
                                             }
                                             
                                             self._serverErrorOverlay.tryAgainbutton.enabled = YES;
                                             [self.view addSubview:_serverErrorOverlay];
                                         }
                                         else {
                                             // Handle possible no connection
                                             if ([[JustLandedSession sharedSession] isJustLandedReachable]) {
                                                 // JL is reachable, we must be having an outage
                                                 self._serverErrorOverlay.errorType = ERROR_503;
                                                 self._serverErrorOverlay.tryAgainbutton.enabled = YES;
                                                 [self.view addSubview:_serverErrorOverlay];
                                             }
                                             else {
                                                 // JL is not reachable - no connection
                                                 if (!_noConnectionOverlay) {
                                                     self._noConnectionOverlay = [[JLNoConnectionView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                                                      0.0f,
                                                                                                                                      320.0f,
                                                                                                                                      460.0f)];
                                                     self._noConnectionOverlay.frame = CGRectMake(0.0f,
                                                                                                  -44.0f,
                                                                                                  320.0f,
                                                                                                  460.0f);
                                                     self._noConnectionOverlay.noConnectionImageView.frame = CGRectMake(_noConnectionOverlay.noConnectionImageView.frame.origin.x,
                                                                                                                        70.0f,
                                                                                                                        _noConnectionOverlay.noConnectionImageView.frame.size.width,
                                                                                                                        _noConnectionOverlay.noConnectionImageView.frame.size.height);
                                                     self._noConnectionOverlay.delegate = self;
                                                 }
                                                 
                                                 self._noConnectionOverlay.tryAgainbutton.enabled = YES;
                                                 [self.view addSubview:_noConnectionOverlay];
                                            }
                                         }
                                     }];
    
    [self indicateLoading];
    [client enqueueHTTPRequestOperation:operation];
}


- (void)indicateLoading {
    [_noConnectionOverlay removeFromSuperview];
    [_serverErrorOverlay removeFromSuperview];
    [webView setHidden:YES];
    
    if (!_loadingOverlay) {
        self._loadingOverlay = [[JLLoadingView alloc] initWithFrame:CGRectMake(0.0f,
                                                                               0.0f,
                                                                               320.0f,
                                                                               460.0f)];
        self._loadingOverlay.frame = CGRectMake(0.0f,
                                                -44.0f,
                                                320.0f,
                                                460.0f);
    }
    
    [self.view addSubview:_loadingOverlay];
    [_loadingOverlay startLoading];
}


- (void)indicateStoppedLoading {
    [_loadingOverlay stopLoading];
    [_loadingOverlay removeFromSuperview];
}


- (void)tryConnectionAgain {
    [self loadContent];
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    //Process anchor links
    if ([_contentURL fragment]) {
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash='%@';", [_contentURL fragment]]];
    }
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
    
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    self.webView.scrollView.alwaysBounceVertical = NO;
    self.webView.scrollView.alwaysBounceHorizontal = NO;
    self.webView.scrollView.bounces = NO;
	self.webView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.layer.cornerRadius = 6.0f;
    self.webView.clipsToBounds = YES;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.webView.hidden = YES;
    self.webView.delegate = self;
    [self.view addSubview:blackBG];
	[self.view addSubview:webView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = _contentTitle;
    
    // Customize the navbar
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5f;
    self.navigationController.navigationBar.layer.shadowRadius = 0.25f;
    self.navigationController.navigationBar.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self.navigationController.navigationBar bounds]] CGPath]; //Optimization avoids offscreen render pass
    
	[self loadContent];
}


- (void)viewDidUnload {
    [super viewDidUnload];
	self.webView = nil;
    self._noConnectionOverlay = nil;
    self._serverErrorOverlay = nil;
}


- (void)dealloc {
    self.webView.delegate = nil;
    self._noConnectionOverlay.delegate = nil;
    self._serverErrorOverlay.delegate = nil;
}

@end
