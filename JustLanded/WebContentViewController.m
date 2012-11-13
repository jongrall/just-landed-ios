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

@property (strong, nonatomic) NSString *contentTitle_;
@property (strong, nonatomic) NSURL *contentURL_;
@property (strong, nonatomic) JLLoadingView *loadingOverlay_;
@property (strong, nonatomic) JLNoConnectionView *noConnectionOverlay_;
@property (strong, nonatomic) JLServerErrorView *serverErrorOverlay_;
@property (nonatomic) BOOL showDoneButton_;

- (void)indicateLoading;
- (void)indicateStoppedLoading;
- (void)loadContent;
- (void)dismiss;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation WebContentViewController

@synthesize webView = webView_;
@synthesize contentTitle_;
@synthesize contentURL_;
@synthesize loadingOverlay_;
@synthesize noConnectionOverlay_;
@synthesize serverErrorOverlay_;
@synthesize showDoneButton_;


- (id)initWithContentTitle:(NSString *)aTitle URL:(NSURL *)aContentURL showDoneButton:(BOOL)flag {
    self = [super init];
    
    if (self) {
        contentTitle_ = (aTitle) ? aTitle : @"Untitled";
        contentURL_ = (aContentURL) ? aContentURL : [NSURL URLWithString:@"about:blank"];
        showDoneButton_ = flag;
    }
    
    return self;
}

- (void)loadContent {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:self.contentURL_];
    [req setTimeoutInterval:15.0];
    [req setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    // Compute base URL
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", [self.contentURL_ scheme], [self.contentURL_ host]]];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    
    // Use iOS user agent string
    NSString *userAgent = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    [client setDefaultHeader:@"User-Agent" value:userAgent];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *theOperation, id responseObject) {
        [self performSelector:@selector(indicateStoppedLoading) withObject:nil afterDelay:1.0]; // Delay prevents white flash as webview loads content
        NSString *responseString = [theOperation responseString];
        [self.webView setHidden:NO];
        [self.webView loadHTMLString:responseString baseURL:[NSURL URLWithString:WEB_HOST]];
    }
                                     failure:^(AFHTTPRequestOperation *theOperation, NSError *failure) {
                                         [self indicateStoppedLoading];
                                         NSHTTPURLResponse *response = [theOperation response];
                                         CGRect screenBounds = [[UIScreen mainScreen] bounds];
                                         
                                         if (!self.serverErrorOverlay_) {
                                             self.serverErrorOverlay_ = [[JLServerErrorView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                                            0.0f,
                                                                                                                            screenBounds.size.width,
                                                                                                                            screenBounds.size.height - 20.0f) // Status bar
                                                                                                       errorType:ERROR_500];
                                             // Move it under the navbar
                                             self.serverErrorOverlay_.frame = CGRectMake(0.0f,
                                                                                         -44.0f, // Navbar height
                                                                                         screenBounds.size.width,
                                                                                         screenBounds.size.height - 20.0f); // Status bar
                                             self.serverErrorOverlay_.delegate = self;
                                         }
                                         
                                         if (response) {
                                             switch ([response statusCode]) {
                                                 case 503: {
                                                     self.serverErrorOverlay_.errorType = ERROR_503;
                                                     break;
                                                 }
                                                 default: {
                                                     self.serverErrorOverlay_.errorType = ERROR_500;
                                                     break;
                                                 }
                                             }
                                             
                                             self.serverErrorOverlay_.tryAgainButton.enabled = YES;
                                             [self.view addSubview:self.serverErrorOverlay_];
                                         }
                                         else {
                                             // Handle possible no connection
                                             if ([[JustLandedSession sharedSession] isJustLandedReachable]) {
                                                 // JL is reachable, we must be having an outage
                                                 self.serverErrorOverlay_.errorType = ERROR_503;
                                                 self.serverErrorOverlay_.tryAgainButton.enabled = YES;
                                                 [self.view addSubview:self.serverErrorOverlay_];
                                             }
                                             else {
                                                 // JL is not reachable - no connection
                                                 if (!self.noConnectionOverlay_) {
                                                     self.noConnectionOverlay_ = [[JLNoConnectionView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                                                      0.0f,
                                                                                                                                      screenBounds.size.width,
                                                                                                                                      screenBounds.size.height - 20.0f)]; // Status bar
                                                     // Move it under the navbar
                                                     self.noConnectionOverlay_.frame = CGRectMake(0.0f,
                                                                                                  -44.0f, // Navbar height
                                                                                                  screenBounds.size.width,
                                                                                                  screenBounds.size.height - 20.0f); // Status bar
                                                     CGFloat noConnectionImageViewOriginY = [UIScreen isMainScreenWide] ? 110.0f : 70.0f;
                                                     self.noConnectionOverlay_.noConnectionImageView.frame = CGRectMake(self.noConnectionOverlay_.noConnectionImageView.frame.origin.x,
                                                                                                                        noConnectionImageViewOriginY,
                                                                                                                        self.noConnectionOverlay_.noConnectionImageView.frame.size.width,
                                                                                                                        self.noConnectionOverlay_.noConnectionImageView.frame.size.height);
                                                     self.noConnectionOverlay_.delegate = self;
                                                 }
                                                 
                                                 self.noConnectionOverlay_.tryAgainButton.enabled = YES;
                                                 [self.view addSubview:self.noConnectionOverlay_];
                                            }
                                         }
                                     }];
    
    [self indicateLoading];
    [client enqueueHTTPRequestOperation:operation];
}


- (void)indicateLoading {
    [self.noConnectionOverlay_ removeFromSuperview];
    [self.serverErrorOverlay_ removeFromSuperview];
    [self.webView setHidden:YES];
    
    if (!self.loadingOverlay_) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.loadingOverlay_ = [[JLLoadingView alloc] initWithFrame:CGRectMake(0.0f,
                                                                               0.0f,
                                                                               screenBounds.size.width,
                                                                               screenBounds.size.height - 20.0f)]; // Status bar
        // Move it under the navbar
        self.loadingOverlay_.frame = CGRectMake(0.0f,
                                                -44.0f, // Navbar height
                                                screenBounds.size.width,
                                                screenBounds.size.height - 20.0f); // Status bar
    }
    
    [self.view addSubview:self.loadingOverlay_];
    [self.loadingOverlay_ startLoading];
}


- (void)indicateStoppedLoading {
    [self.loadingOverlay_ stopLoading];
    [self.loadingOverlay_ removeFromSuperview];
}


- (void)tryConnectionAgain {
    [self loadContent];
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    //Process anchor links
    if ([self.contentURL_ fragment]) {
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash='%@';", [self.contentURL_ fragment]]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                screenBounds.size.width,
                                                                screenBounds.size.height - 64.0f)]; // Status bar + navbar
    mainView.backgroundColor = [UIColor colorWithRed:231/255.0f green:228/255.0f blue:223.0f/255.0f alpha:1.0f];
    self.view = mainView;
    
    // Add a black BG
    UIView *blackBG = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                               200.0f,
                                                               screenBounds.size.width,
                                                               mainView.frame.size.height - 200.0f)];
    blackBG.backgroundColor = [UIColor blackColor];
    
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, mainView.frame.size.width, mainView.frame.size.height)];
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
	[self.view addSubview:self.webView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = self.contentTitle_;
    
    // Customize the navbar
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5f;
    self.navigationController.navigationBar.layer.shadowRadius = 0.25f;
    self.navigationController.navigationBar.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self.navigationController.navigationBar bounds]] CGPath]; //Optimization avoids offscreen render pass
    
    // Customize the right bar button item
    if (self.showDoneButton_) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(dismiss)];
    }

	[self loadContent];
}


- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)viewDidUnload {
    [super viewDidUnload];
	self.webView = nil;
    self.noConnectionOverlay_ = nil;
    self.serverErrorOverlay_ = nil;
}


- (void)dealloc {
    webView_.delegate = nil;
    noConnectionOverlay_.delegate = nil;
    serverErrorOverlay_.delegate = nil;
}

@end
