//
//  FlightTrackViewController.m
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "FlightTrackViewController.h"
#import "AboutViewController.h"
#import "JustLandedSession.h"
#import "Flight.h"
#import "FlurryAnalytics.h"
#import <CoreLocation/CoreLocation.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FlightTrackViewController() {
    __strong Flight *_trackedFlight;
}

@property (strong, nonatomic) JLStatusLabel *_statusLabel;
@property (strong, nonatomic) JLStatusLabel *_originCodeLabel;
@property (strong, nonatomic) JLStatusLabel *_originCityLabel;
@property (strong, nonatomic) JLStatusLabel *_destinationCodeLabel;
@property (strong, nonatomic) JLStatusLabel *_destinationCityLabel;
@property (strong, nonatomic) JLFlightProgressView *_flightProgressView;
@property (strong, nonatomic) JLLabel *_landsAtLabel;
@property (strong, nonatomic) JLMultipartLabel *_landsAtTimeLabel;
@property (strong, nonatomic) JLLabel *_terminalLabel;
@property (strong, nonatomic) JLLabel *_terminalValueLabel;
@property (strong, nonatomic) UIImageView *_arrowView;
@property (strong, nonatomic) UIImageView *_headerBackground;
@property (strong, nonatomic) UIImageView *_footerBackground;
@property (strong, nonatomic) JLLookupButton *_lookupButton;
@property (strong, nonatomic) JLButton *_directionsButton;
@property (strong, nonatomic) JLButton *_infoButton;
@property (strong, nonatomic) JLLeaveMeter *_leaveMeter;

+ (UIImage *)arrowImageForStatus:(FlightStatus)status;
+ (UIImage *)headerBackgroundImageForStatus:(FlightStatus)status;

- (NSString *)labelForStatus:(FlightStatus)status;
- (void)trackFlightWithLocation:(CLLocation *)loc;
- (void)locationUpdated:(NSNotification *)notification;
- (void)locationUpdateFailed:(NSNotification *)notification;
- (void)triedToRegisterForRemoteNotifications:(NSNotification *)notification;
- (void)willTrackFlight:(NSNotification *)notification;
- (void)didTrackFlight:(NSNotification *)notification;
- (void)flightTrackFailed:(NSNotification *)notification;
- (void)refreshOnResume;
- (void)startUpdating;
- (void)stopUpdating;
- (void)setFlightNumber:(NSString *)fnum;
- (void)setStatus:(FlightStatus)newStatus;
- (NSString *)landsAtLabelText;
- (NSString *)landsAtTime;
- (NSString *)terminalLabelText;
- (NSString *)terminalValue;
- (NSString *)blankValue;
- (void)showAboutScreen;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FlightTrackViewController

@synthesize delegate;
@synthesize trackedFlight=_trackedFlight;
@synthesize _statusLabel;
@synthesize _originCodeLabel;
@synthesize _originCityLabel;
@synthesize _destinationCodeLabel;
@synthesize _destinationCityLabel;
@synthesize _flightProgressView;
@synthesize _landsAtLabel;
@synthesize _landsAtTimeLabel;
@synthesize _terminalLabel;
@synthesize _terminalValueLabel;
@synthesize _arrowView;
@synthesize _headerBackground;
@synthesize _footerBackground;
@synthesize _lookupButton;
@synthesize _directionsButton;
@synthesize _infoButton;
@synthesize _leaveMeter;


+ (UIImage *)arrowImageForStatus:(FlightStatus)status {
    return [UIImage imageNamed:@"arrow" 
                     withColor:[UIColor whiteColor] 
                   shadowColor:[JLStyles labelShadowColorForStatus:status] 
                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                    shadowBlur:1.0f];
}


+ (UIImage *)headerBackgroundImageForStatus:(FlightStatus)status {
    NSString *fileName = [NSString stringWithFormat:@"tracking_header_bg_%@", [JLStyles colorNameForStatus:status]];
    return [UIImage imageNamed:fileName];
}


- (NSString *)labelForStatus:(FlightStatus)status {
    // Note: Spaces added at the end to work with script font.
    switch (status) {
        case SCHEDULED:
            return NSLocalizedString(@"scheduled ", @"Scheduled Label Text");
            break;
        case ON_TIME:
            return NSLocalizedString(@"on time ", @"On Time Label Text");
            break;
        case DELAYED:
            return NSLocalizedString(@"delayed ", @"Delayed Label Text");
            break;
        case CANCELED:
            return NSLocalizedString(@"canceled ", @"Canceled Label Text");
            break;
        case DIVERTED:
            return NSLocalizedString(@"diverted ", @"Diverted Label Text");
            break;
        case LANDED: {
            if ([[NSDate date] timeIntervalSinceDate:_trackedFlight.actualArrivalTime] < 300.0) {
                return NSLocalizedString(@"just landed ", @"Just Landed Label Text"); // Landed in last 5 minutes
            }
            else {
                return NSLocalizedString(@"landed ", @"Landed Label Text");
            }
            break;
        }
        case EARLY:
            return NSLocalizedString(@"early ", @"Early Label Text");
            break;
        default:
            return NSLocalizedString(@"status unknown ", @"unknown Label Text");
            break;
    }
}


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
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(triedToRegisterForRemoteNotifications:) 
                                                     name:DidRegisterForRemoteNotifications 
                                                   object:[JustLandedSession sharedSession]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(triedToRegisterForRemoteNotifications:) 
                                                     name:DidFailToRegisterForRemoteNotifications 
                                                   object:[JustLandedSession sharedSession]];
    
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
        
        // Initiate a refresh to get the initial flight information
        [self refresh];
    }
    
    return self;
}


- (void)trackFlightWithLocation:(CLLocation *)loc {
    if ([[JustLandedSession sharedSession] triedToRegisterForRemoteNotifications] &&
        ([[JustLandedSession sharedSession] triedToGetLocation] || 
         ![[JustLandedSession sharedSession] locationServicesAvailable])) {
        [_trackedFlight trackWithLocation:loc pushEnabled:[[JustLandedSession sharedSession] pushEnabled]];
    }
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


- (void)startUpdating {
    
}


- (void)stopUpdating {
    
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


- (void)triedToRegisterForRemoteNotifications:(NSNotification *)notification {
    [self trackFlightWithLocation:[[JustLandedSession sharedSession] lastKnownLocation]];
}


- (void)willTrackFlight:(NSNotification *)notification {
    [self startUpdating];
}


- (void)didTrackFlight:(NSNotification *)notification {
    // Stop loading animation
    [self stopUpdating];
    
    // Update displayed information
    [self setStatus:_trackedFlight.status];
    [self setFlightNumber:_trackedFlight.flightNumber];
    _originCodeLabel.text = _trackedFlight.origin.bestCode;
    _originCityLabel.text = [_trackedFlight.origin.city uppercaseString];
    _destinationCodeLabel.text = _trackedFlight.destination.bestCode;
    _destinationCityLabel.text = [_trackedFlight.destination.city uppercaseString];
    _flightProgressView.timeOfDay = [_trackedFlight timeOfDay];
    _flightProgressView.aircraftType = [_trackedFlight aircraftType];
    _flightProgressView.progress = [_trackedFlight currentProgress];
    _landsAtLabel.text = [self landsAtLabelText];
    _landsAtTimeLabel.parts = [[self landsAtTime] componentsSeparatedByString:@" "];
    _terminalLabel.text = [self terminalLabelText];
    _terminalValueLabel.text = [self terminalValue];
    
    if (_trackedFlight.leaveForAirporTime) {
        self._leaveMeter.timeRemaining = [_trackedFlight.leaveForAirporTime timeIntervalSinceNow];
        self._leaveMeter.hidden = NO;
    }
    else {
        self._leaveMeter.hidden = YES;
    }
    
    // Hide the directions button if appropriate
    if (_trackedFlight.leaveForAirporTime) {
        [_directionsButton setHidden:NO];
    }
    else {
        [_directionsButton setHidden:YES];
    }
    
    // Ask them to rate after a few seconds, if eligible
    [[JustLandedSession sharedSession] performSelector:@selector(showRatingRequestIfEligible) 
                                            withObject:nil 
                                            afterDelay:4.0];
}


- (void)flightTrackFailed:(NSNotification *)notification {
    [self stopUpdating];
    
    FlightTrackFailedReason reason = [[[notification userInfo] valueForKey:FlightTrackFailedReasonKey] intValue];
    
    if (reason == TrackFailureFlightNotFound || reason == TrackFailureInvalidFlightNumber || reason == TrackFailureOldFlight) {
        // Old flight, not found flight, invalid flight is not recoverable, go back to lookup interface
        [delegate didFinishTracking:self userInitiated:NO];
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
    [mainView setBackgroundColor:[UIColor blackColor]];
    self.view = mainView;
    
    // Create the footer background
    _footerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracking_footer_bg"]];
    [_footerBackground setFrame:TRACK_FOOTER_FRAME];
    
    // Create the header background
    _headerBackground = [[UIImageView alloc] initWithImage:[[self class] headerBackgroundImageForStatus:_trackedFlight.status]];
    [_headerBackground setFrame:TRACK_HEADER_FRAME];
                         
    // Create the lookup button
    _lookupButton = [[JLLookupButton alloc] initWithButtonStyle:[JLTrackStyles lookupButtonStyle] frame:CGRectZero status:_trackedFlight.status];
    [_lookupButton addTarget:self action:@selector(stopTracking) forControlEvents:UIControlEventTouchUpInside];
    [self setFlightNumber:_trackedFlight.flightNumber];
    
    // Create the status label
    _statusLabel = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles statusLabelStyle] frame:STATUS_LABEL_FRAME status:_trackedFlight.status];
    
    //Create the arrow view
    UIImage *arrowImage = [[self class] arrowImageForStatus:_trackedFlight.status];
    _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(ARROW_ORIGIN.x, ARROW_ORIGIN.y, arrowImage.size.width, arrowImage.size.height)];
    [_arrowView setImage:arrowImage];
    
    // Create the airport code labels
    _originCodeLabel = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles airportCodeStyle] frame:ORIGIN_CODE_LABEL_FRAME status:_trackedFlight.status];
    _originCodeLabel.text = _trackedFlight.origin.bestCode;
    _destinationCodeLabel = [[JLStatusLabel alloc]  initWithLabelStyle:[JLTrackStyles airportCodeStyle] frame:DESTINATION_CODE_LABEL_FRAME status:_trackedFlight.status];
    _destinationCodeLabel.text = _trackedFlight.destination.bestCode;
    
    // Create the city labels
    _originCityLabel = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles cityNameStyle] frame:ORIGIN_CITY_LABEL_FRAME status:_trackedFlight.status];
    _originCityLabel.text = [_trackedFlight.origin.city uppercaseString];
    _destinationCityLabel = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles cityNameStyle] frame:DESTINATION_CITY_LABEL_FRAME status:_trackedFlight.status];
    _destinationCityLabel.text = [_trackedFlight.destination.city uppercaseString];
    
    // Add the flight progress view
    _flightProgressView = [[JLFlightProgressView alloc] initWithFrame:FLIGHT_PROGRESS_FRAME 
                                                             progress:[_trackedFlight currentProgress]
                                                            timeOfDay:[_trackedFlight timeOfDay]
                                                         aircraftType:[_trackedFlight aircraftType]];
    
    // Add the lands at labels
    _landsAtLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:LANDS_AT_LABEL_FRAME];
    _landsAtLabel.text = [self landsAtLabelText];
    _landsAtTimeLabel = [[JLMultipartLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles flightDataValueStyle], [JLTrackStyles timeUnitLabelStyle], nil]
                                                                frame:LANDS_AT_TIME_FRAME];
    _landsAtTimeLabel.parts = [NSArray arrayWithObject:[self blankValue]];
    _landsAtTimeLabel.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero], [NSValue valueWithCGSize:TIME_UNIT_OFFSET], nil];
    
    // Add the terminal info
    _terminalLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:TERMINAL_LABEL_FRAME];
    _terminalLabel.text = [self terminalLabelText];
    _terminalValueLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle] frame:TERMINAL_VALUE_FRAME];
    _terminalValueLabel.text = [self blankValue];
    
    // Create the directions button
    _directionsButton = [[JLButton alloc] initWithButtonStyle:[JLTrackStyles directionsButtonStyle] frame:DIRECTIONS_BUTTON_FRAME];
    [_directionsButton addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    _directionsButton.hidden = YES;
    
    // Create the info button
    _infoButton = [[JLButton alloc] initWithButtonStyle:[JLTrackStyles infoButtonStyle] frame:INFO_BUTTON_FRAME];
    [_infoButton addTarget:self action:@selector(showAboutScreen) forControlEvents:UIControlEventTouchUpInside];
    
    // Create the gauge
    _leaveMeter = [[JLLeaveMeter alloc] initWithFrame:LEAVE_IN_GAUGE_FRAME];
    _leaveMeter.hidden = YES;
    
    // Add them to the view
    [self.view addSubview:_footerBackground];
    [self.view addSubview:_headerBackground];
    [self.view addSubview:_lookupButton];
    [self.view addSubview:_statusLabel];
    [self.view addSubview:_arrowView];
    [self.view addSubview:_originCodeLabel];
    [self.view addSubview:_destinationCodeLabel];
    [self.view addSubview:_originCityLabel];
    [self.view addSubview:_flightProgressView];
    [self.view addSubview:_landsAtLabel];
    [self.view addSubview:_landsAtTimeLabel];
    [self.view addSubview:_terminalLabel];
    [self.view addSubview:_terminalValueLabel];
    [self.view addSubview:_destinationCityLabel];
    [self.view addSubview:_directionsButton];
    [self.view addSubview:_infoButton];
    [self.view addSubview:_leaveMeter];
    
    [self setStatus:_trackedFlight.status];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self._statusLabel = nil;
    self._originCodeLabel = nil;
    self._originCityLabel = nil;
    self._destinationCodeLabel = nil;
    self._destinationCityLabel = nil;
    self._flightProgressView = nil;
    self._landsAtLabel = nil;
    self._landsAtTimeLabel = nil;
    self._terminalLabel = nil;
    self._terminalValueLabel = nil;
    self._arrowView = nil;
    self._headerBackground = nil;
    self._footerBackground = nil;
    self._lookupButton = nil;
    self._directionsButton = nil;
    self._infoButton = nil;
    self._leaveMeter = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Only supports portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)setFlightNumber:(NSString *)fnum {
    // Update the button title
    [_lookupButton setTitle:fnum forState:UIControlStateNormal];
    
    // Update the button size
    CGSize labelSize = [fnum sizeWithFont:[[[[JLTrackStyles lookupButtonStyle] labelStyle] textStyle] font]];
    UIEdgeInsets labelInsets = [[JLTrackStyles lookupButtonStyle] labelInsets];
    [_lookupButton setFrame:CGRectMake(LOOKUP_BUTTON_ORIGIN.x,
                                       LOOKUP_BUTTON_ORIGIN.y,
                                       labelSize.width + labelInsets.left + labelInsets.right,
                                       34.0f)];    
}


- (void)setStatus:(FlightStatus)newStatus {
    // Set the background image
    _headerBackground.image = [[self class] headerBackgroundImageForStatus:newStatus];
    
    // Update the elements affected by status color
    [_lookupButton setStatus:newStatus];
    [_statusLabel setStatus:newStatus];
    [_originCodeLabel setStatus:newStatus];
    [_originCityLabel setStatus:newStatus];
    [_destinationCodeLabel setStatus:newStatus];
    [_destinationCityLabel setStatus:newStatus];
    
    // Set the status label text
    [_statusLabel setText:[self labelForStatus:newStatus]];
}


- (NSString *)landsAtLabelText {
    if ([_trackedFlight actualArrivalTime]) {
        return [[NSString stringWithFormat:@"LANDED %@ AT", [NSDate naturalDayStringFromDate:[_trackedFlight actualArrivalTime]]] uppercaseString];
    }
    else {
        return [[NSString stringWithFormat:@"LANDS %@ AT", [NSDate naturalDayStringFromDate:[_trackedFlight estimatedArrivalTime]]] uppercaseString];
    }
}


- (NSString *)landsAtTime {
    if ([_trackedFlight actualArrivalTime]) {
        return [NSDate naturalTimeStringFromDate:[_trackedFlight actualArrivalTime]];
    }
    else {
        return [NSDate naturalTimeStringFromDate:[_trackedFlight estimatedArrivalTime]];
    }
}


- (NSString *)terminalLabelText {
    return NSLocalizedString(@"TERMINAL", @"Terminal Label");
}


- (NSString *)terminalValue {
    if (_trackedFlight.destination.terminal && [_trackedFlight.destination.terminal length] > 0) {
        if ([_trackedFlight.destination.terminal isEqualToString:@"I"]) {
            return NSLocalizedString(@"INT'L", @"International Abbreviated");
        }
        else {
            return [_trackedFlight.destination.terminal uppercaseString];
        }
    }
    else {
        return [self blankValue];
    }
}


- (NSString *)blankValue {
    return @"--";
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)stopTracking {
    [self stopUpdating];
    [_trackedFlight stopTracking];
    [self.delegate didFinishTracking:self userInitiated:YES];
}


- (void)showMap {
    NSString *mapURL = nil;
    NSString *destName = (_trackedFlight.destination.iataCode) ? _trackedFlight.destination.iataCode : 
                                                                 _trackedFlight.destination.icaoCode;
    destName = [destName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *destLoc = [NSString stringWithFormat:@"%f,%f", 
                         _trackedFlight.destination.location.coordinate.latitude,
                         _trackedFlight.destination.location.coordinate.longitude];
    
    mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@&layer=t&t=m",
              @"Current%20Location",
              [NSString stringWithFormat:@"%@@%@", destName, destLoc]];

    [FlurryAnalytics logEvent:FY_GOT_DIRECTIONS];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURL]];
}


- (void)refresh {
    CLLocation *location = [[JustLandedSession sharedSession] lastKnownLocation];
    
    if (location) {
        // We already have a location (it may be stale), track now
        [self trackFlightWithLocation:location];
    }
}


- (void)showAboutScreen {
    AboutViewController *aboutController = [[AboutViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutController];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navController animated:YES];
    [FlurryAnalytics logEvent:FY_VISITED_ABOUT_SCREEN];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
