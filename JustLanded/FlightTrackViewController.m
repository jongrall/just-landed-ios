//
//  FlightTrackViewController.m
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "FlightTrackViewController.h"
#import "JustLandedSession.h"
#import <CoreLocation/CoreLocation.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FlightTrackViewController() {
    __strong Flight *_trackedFlight;
}

@property (strong, nonatomic) UITextView *_textView;
@property (strong, nonatomic) UILabel *_lastTrackedLabel;
@property (strong, nonatomic) UIButton *_refreshButton;
@property (strong, nonatomic) UIButton *_lookupButton;
@property (strong, nonatomic) UIActivityIndicatorView *_updatingSpinner;

- (void)trackFlightWithLocation:(CLLocation *)loc;
- (void)locationUpdated:(NSNotification *)notification;
- (void)locationUpdateFailed:(NSNotification *)notification;
- (void)willTrackFlight:(NSNotification *)notification;
- (void)didTrackFlight:(NSNotification *)notification;
- (void)flightTrackFailed:(NSNotification *)notification;
- (void)refreshOnResume;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FlightTrackViewController

@synthesize delegate;
@synthesize trackedFlight=_trackedFlight;
@synthesize _textView;
@synthesize _lastTrackedLabel;
@synthesize _refreshButton;
@synthesize _lookupButton;
@synthesize _updatingSpinner;

- (id)initWithFlight:(Flight *)aFlight {
    self = [super init];
    
    if (self) {
        NSAssert((aFlight != nil), @"Flight to track is nil!");
        _trackedFlight = aFlight;
        
        // Listen for location update notifications
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(locationUpdated:) 
                                                     name:LastKnownLocationDidUpdateNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(locationUpdateFailed:) 
                                                     name:LastKnownLocationDidFailToUpdateNotification 
                                                   object:nil];
    
        // Listen for notifications for the Flight
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(willTrackFlight:)
                                                     name:WillTrackFlightNotification 
                                                   object:aFlight];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didTrackFlight:)
                                                     name:DidTrackFlightNotification 
                                                   object:aFlight];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(flightTrackFailed:)
                                                     name:FlightTrackFailedNotification 
                                                   object:aFlight];
        
        // Setup refresh on resume
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(refreshOnResume) 
                                                     name:UIApplicationWillResignActiveNotification 
                                                   object:[UIApplication sharedApplication]];
    }
    
    return self;
}

- (void)trackFlightWithLocation:(CLLocation *)loc {
    [_trackedFlight trackWithLocation:loc pushEnabled:[[JustLandedSession sharedSession] pushEnabled]];
}


- (void)refreshOnResume {
    // Listen for resume notifications and refresh on resume
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidBecomeActiveNotification 
                                                  object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(refresh) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:[UIApplication sharedApplication]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Respond To Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)locationUpdated:(NSNotification *)notification {
    // Update tracking information
    CLLocation *newLocation = [[notification userInfo] valueForKey:@"location"];
    [self trackFlightWithLocation:newLocation];    
}


- (void)locationUpdateFailed:(NSNotification *)notification {
    // Track anyway, without location
    [self trackFlightWithLocation:nil];
    
    // TODO: Indicate that we don't have location?
}


- (void)willTrackFlight:(NSNotification *)notification {
    self._lastTrackedLabel.hidden = YES;
    self._refreshButton.enabled = NO;
    [self._updatingSpinner startAnimating];
    
}


- (void)didTrackFlight:(NSNotification *)notification {
    // Stop loading animation
    self._lastTrackedLabel.text = [NSString stringWithFormat:@"Last updated %@", [NSDate naturalDateStringFromDate:[_trackedFlight lastTracked]]];
    [self._updatingSpinner stopAnimating];
    self._lastTrackedLabel.hidden = NO;
    self._refreshButton.enabled = YES;
    
    // Update displayed information
    self._textView.text = [_trackedFlight description];
}


- (void)flightTrackFailed:(NSNotification *)notification {
    [self._updatingSpinner stopAnimating];
    self._lastTrackedLabel.hidden = NO;
    self._refreshButton.enabled = YES;
    
    FlightTrackFailedReason reason = [[[notification userInfo] valueForKey:FlightTrackFailedReasonKey] intValue];
    
    if (reason != TrackFailureNoConnection) {
        [delegate didFinishTracking:self];
    }
    else {
        // TODO: Handle no connection
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)loadView {
    // Set up the main view
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    [mainView setBackgroundColor:[UIColor grayColor]];
    self.view = mainView;
    
    // Add a display text area to the view
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 280.0f, 340.0f)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:12.0f];
    textView.textColor = [UIColor darkGrayColor];
    textView.textAlignment = UITextAlignmentLeft;
    textView.editable = NO;
    self._textView = textView;
    [self.view addSubview:textView];
    
    // Add a button to refresh
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    refreshButton.frame = CGRectMake(20.0f, 380.0f, 100.0f, 40.0f);
    refreshButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    self._refreshButton = refreshButton;
    [self.view addSubview:refreshButton];
    
    // Add a button to lookup flights
    UIButton *lookupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lookupButton.frame = CGRectMake(200.0f, 380.0f, 100.0f, 40.0f);
    lookupButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [lookupButton setTitle:@"Lookup" forState:UIControlStateNormal];
    [lookupButton addTarget:self action:@selector(stopTracking) forControlEvents:UIControlEventTouchUpInside];
    self._lookupButton = lookupButton;
    [self.view addSubview:lookupButton];
    
    // Add a label to show when last tracked
    UILabel *lastTrackedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 425.0f, 280.0f, 20.0f)];
    lastTrackedLabel.textColor = [UIColor darkGrayColor];
    lastTrackedLabel.font = [UIFont systemFontOfSize:10.0f];
    lastTrackedLabel.textAlignment = UITextAlignmentCenter;
    lastTrackedLabel.backgroundColor = [UIColor clearColor];
    lastTrackedLabel.hidden = YES;
    self._lastTrackedLabel = lastTrackedLabel;
    [self.view addSubview:lastTrackedLabel];
    
    // Add a spinner to show when updating
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                        UIActivityIndicatorViewStyleWhite];
    spinner.frame = CGRectMake(160.0f - (spinner.frame.size.width / 2.0f),
                               435.0 - (spinner.frame.size.height / 2.0f),
                               spinner.frame.size.width,
                               spinner.frame.size.height);
    spinner.hidesWhenStopped = YES;
    self._updatingSpinner = spinner;
    [self.view addSubview:spinner];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self._textView = nil;
    self._lastTrackedLabel = nil;
    self._refreshButton = nil;
    self._lookupButton = nil;
    self._updatingSpinner = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Only supports portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)stopTracking {
    [_trackedFlight stopTracking];
    [self.delegate didFinishTracking:self];
}


- (void)refresh {
    CLLocation *location = [[JustLandedSession sharedSession] lastKnownLocation];
    
    if (location) {
        // We already have a location (it may be stale), track now
        [self trackFlightWithLocation:location];
    }
}


- (void)showPickupDirections {
    // TODO: display external google map / mapkit?
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
