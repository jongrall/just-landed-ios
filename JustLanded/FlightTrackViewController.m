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

@property (strong, nonatomic) NSTimer *_updateTimer;
@property (strong, nonatomic) NSTimer *_alternatingLabelTimer;
@property (strong, nonatomic) JLStatusLabel *_statusLabel;
@property (strong, nonatomic) JLStatusLabel *_originCodeLabel;
@property (strong, nonatomic) JLStatusLabel *_originCityLabel;
@property (strong, nonatomic) JLStatusLabel *_destinationCodeLabel;
@property (strong, nonatomic) JLStatusLabel *_destinationCityLabel;
@property (strong, nonatomic) JLFlightProgressView *_flightProgressView;
@property (strong, nonatomic) JLLabel *_landsAtLabel;
@property (strong, nonatomic) JLMultipartLabel *_landsAtTimeLabel;
@property (strong, nonatomic) JLLabel *_landsInLabel;
@property (strong, nonatomic) JLMultipartLabel *_landsInTimeLabel;
@property (strong, nonatomic) JLLabel *_terminalLabel;
@property (strong, nonatomic) JLLabel *_terminalValueLabel;
@property (strong, nonatomic) JLLabel *_gateLabel;
@property (strong, nonatomic) JLLabel *_gateValueLabel;
@property (strong, nonatomic) JLLabel *_drivingTimeLabel;
@property (strong, nonatomic) JLMultipartLabel *_drivingTimeValueLabel;
@property (strong, nonatomic) JLLabel *_bagClaimLabel;
@property (strong, nonatomic) JLLabel *_bagClaimValueLabel;
@property (strong, nonatomic) UIImageView *_arrowView;
@property (strong, nonatomic) UIImageView *_headerBackground;
@property (strong, nonatomic) UIImageView *_footerBackground;
@property (strong, nonatomic) JLLookupButton *_lookupButton;
@property (strong, nonatomic) JLButton *_directionsButton;
@property (strong, nonatomic) JLLeaveMeter *_leaveMeter;
@property (strong, nonatomic) JLNoConnectionView *_noConnectionOverlay;
@property (strong, nonatomic) JLServerErrorView *_serverErrorOverlay;
@property (strong, nonatomic) JLLoadingView *_loadingOverlay;
@property (nonatomic) BOOL _showingValidData;

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
- (void)startUpdating;
- (void)stopUpdating;
- (void)stopTrackingUserInitiated:(BOOL)userInitiated;
- (void)setFlightNumber:(NSString *)fnum;
- (void)setStatus:(FlightStatus)newStatus;
- (void)invalidateData;
- (NSString *)landsAtLabelText;
- (NSArray *)landsAtTimeParts;
- (NSArray *)landsAtTimeOffsets;
- (NSString *)landsInLabelText;
- (NSArray *)landsInTimeParts;
- (NSString *)terminalLabelText;
- (NSString *)terminalValue;
- (NSString *)gateLabelText;
- (NSString *)gateValue;
- (NSArray *)drivingTimeParts;
- (NSString *)bagClaimValue;
- (NSString *)blankValue;
- (void)backToLookup;
- (void)showDrivingTimeOrBagClaim;
- (void)updateDisplayedData;
- (void)alternateData;
- (void)fadeOut:(UIView *)aView fadeIn:(UIView *)anotherView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FlightTrackViewController

@synthesize delegate;
@synthesize trackedFlight=_trackedFlight;
@synthesize _updateTimer;
@synthesize _alternatingLabelTimer;
@synthesize _statusLabel;
@synthesize _originCodeLabel;
@synthesize _originCityLabel;
@synthesize _destinationCodeLabel;
@synthesize _destinationCityLabel;
@synthesize _flightProgressView;
@synthesize _landsAtLabel;
@synthesize _landsAtTimeLabel;
@synthesize _landsInLabel;
@synthesize _landsInTimeLabel;
@synthesize _terminalLabel;
@synthesize _terminalValueLabel;
@synthesize _gateLabel;
@synthesize _gateValueLabel;
@synthesize _drivingTimeLabel;
@synthesize _drivingTimeValueLabel;
@synthesize _bagClaimLabel;
@synthesize _bagClaimValueLabel;
@synthesize _arrowView;
@synthesize _headerBackground;
@synthesize _footerBackground;
@synthesize _lookupButton;
@synthesize _directionsButton;
@synthesize _leaveMeter;
@synthesize _noConnectionOverlay;
@synthesize _serverErrorOverlay;
@synthesize _loadingOverlay;
@synthesize _showingValidData;

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
        case DELAYED: {
            // Calculate how late it is
            NSTimeInterval lateAmt = fabs([_trackedFlight.estimatedArrivalTime timeIntervalSinceDate:_trackedFlight.scheduledArrivalTime]);
            
            if (lateAmt > 0.0) {
                NSString *lateAmtText = [NSDate timeIntervalToShortUnitString:lateAmt leadingZeros:NO];
                lateAmtText = [lateAmtText lowercaseString];
                NSArray *parts = [lateAmtText componentsSeparatedByString:@" "];
                
                if ([parts count] > 2) {
                    parts = [parts subarrayWithRange:NSMakeRange(0, 2)];
                    lateAmtText = [parts componentsJoinedByString:@" "];
                }
                
                return [NSString stringWithFormat:NSLocalizedString(@"delayed %@ ", @"Delayed Label Text"), lateAmtText];
            }
            else {
                return NSLocalizedString(@"delayed ", @"Delayed Label Text");
            }
            break;
        }
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
        case EARLY: {
            // Calculate how early it is
            NSTimeInterval earlyAmt = fabs([_trackedFlight.scheduledArrivalTime timeIntervalSinceDate:_trackedFlight.estimatedArrivalTime]);
            if (earlyAmt > 0.0) {
                NSString *earlyAmtText = [NSDate timeIntervalToShortUnitString:earlyAmt leadingZeros:NO];
                earlyAmtText = [earlyAmtText lowercaseString];
                NSArray *parts = [earlyAmtText componentsSeparatedByString:@" "];
                
                if ([parts count] > 2) {
                    parts = [parts subarrayWithRange:NSMakeRange(0, 2)];
                    earlyAmtText = [parts componentsJoinedByString:@" "];
                }
                
                return [NSString stringWithFormat:NSLocalizedString(@"%@ early ", @"Early Label Text"), earlyAmtText];
            }
            else {
                return NSLocalizedString(@"early ", @"Early Label Text");
            }
            break;
        }
        default:
            return NSLocalizedString(@"status unknown ", @"unknown Label Text");
            break;
    }
}


- (id)initWithFlight:(Flight *)aFlight {
    self = [super init];
    
    if (self) {
        NSAssert(aFlight != nil, @"Flight to track is nil!");
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
                                                   object:_trackedFlight];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didTrackFlight:)
                                                     name:DidTrackFlightNotification 
                                                   object:_trackedFlight];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(flightTrackFailed:)
                                                     name:FlightTrackFailedNotification 
                                                   object:_trackedFlight];
        
        // When going to the background, cover the screen with loading        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(invalidateData) 
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        // Track the flight
        [self refresh];
    }
    
    return self;
}


- (void)trackFlightWithLocation:(CLLocation *)loc {
    if ([[JustLandedSession sharedSession] triedToRegisterForRemoteNotifications] &&
        (loc || [[JustLandedSession sharedSession] triedToGetLocation] || 
         ![[JustLandedSession sharedSession] locationServicesAvailable])) {
            [_trackedFlight trackWithLocation:loc pushEnabled:[[JustLandedSession sharedSession] pushEnabled]];
    }
}


- (void)startUpdating {
    [_lookupButton setEnabled:NO];
    [_noConnectionOverlay removeFromSuperview];
    [_serverErrorOverlay removeFromSuperview];
    
    if (!_showingValidData || ![_trackedFlight isDataFresh]) {
        if (!_loadingOverlay) {
            _loadingOverlay = [[JLLoadingView alloc] initWithFrame:self.view.bounds];
        }
        
        [self.view addSubview:_loadingOverlay];
        [_loadingOverlay startLoading];
    }
}


- (void)stopUpdating {
    [_lookupButton setEnabled:YES]; // Disable untrack while tracking (can cause out-of-order bug)
    [_loadingOverlay stopLoading];
    [_loadingOverlay removeFromSuperview];
}


- (void)stopTrackingUserInitiated:(BOOL)userInitiated {
    [_updateTimer invalidate];
    [_alternatingLabelTimer invalidate];
    [_flightProgressView stopAnimating];
    [delegate didFinishTracking:self userInitiated:userInitiated];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)invalidateData {
    // Invalidates that data and covers the screen with loading... so on resume we're showing the right thing.
    self._showingValidData = NO;
    [self startUpdating];
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
    _footerBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Create the header background
    _headerBackground = [[UIImageView alloc] initWithFrame:TRACK_HEADER_FRAME];
                         
    // Create the lookup button
    _lookupButton = [[JLLookupButton alloc] initWithButtonStyle:[JLTrackStyles lookupButtonStyle] frame:CGRectZero status:_trackedFlight.status];
    [_lookupButton addTarget:self action:@selector(backToLookup) forControlEvents:UIControlEventTouchUpInside];
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
    _flightProgressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    // Add the lands at labels
    _landsAtLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:LANDS_AT_LABEL_FRAME];
    _landsAtLabel.text = [self landsAtLabelText];
    _landsAtTimeLabel = [[JLMultipartLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles flightDataValueStyle], [JLTrackStyles timeUnitLabelStyle], [JLTrackStyles timezoneLabelStyle], nil]
                                                                frame:LANDS_AT_TIME_FRAME];
    _landsAtTimeLabel.parts = [self landsAtTimeParts];
    _landsAtTimeLabel.offsets = [self landsAtTimeOffsets];
    _landsAtLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _landsAtTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the lands in labels
    _landsInLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:LANDS_AT_LABEL_FRAME];
    _landsInLabel.text = [self landsInLabelText];
    _landsInTimeLabel = [[JLMultipartLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles flightDataValueStyle], 
                                                                       [JLTrackStyles timeUnitLabelStyle],
                                                                       [JLTrackStyles flightDataValueStyle], 
                                                                       [JLTrackStyles timeUnitLabelStyle], nil] 
                                                                frame:LANDS_AT_TIME_FRAME];
    _landsInTimeLabel.parts = [self landsInTimeParts];
    _landsInTimeLabel.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero], 
                                 [NSValue valueWithCGSize:TIME_UNIT_OFFSET],
                                 [NSValue valueWithCGSize:CGSizeMake(6.0f, 0.0f)], 
                                 [NSValue valueWithCGSize:TIME_UNIT_OFFSET],nil];
    _landsInLabel.alpha = 0.0f;
    _landsInTimeLabel.alpha = 0.0f;
    _landsInLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _landsInTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the terminal info
    _terminalLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:TERMINAL_LABEL_FRAME];
    _terminalLabel.text = [self terminalLabelText];
    _terminalValueLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle] frame:TERMINAL_VALUE_FRAME];
    _terminalValueLabel.text = [self terminalValue];
    _terminalLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _terminalValueLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the gate info
    _gateLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:TERMINAL_LABEL_FRAME];
    _gateLabel.text = [self gateLabelText];
    _gateValueLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle] frame:TERMINAL_VALUE_FRAME];
    _gateValueLabel.text = [self gateValue];
    _gateLabel.alpha = 0.0f;
    _gateValueLabel.alpha = 0.0f;
    _gateLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _gateValueLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the driving time info
    _drivingTimeLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:DRIVING_TIME_LABEL_FRAME];
    _drivingTimeLabel.text = NSLocalizedString(@"DRIVING TIME", @"DRIVING TIME");
    _drivingTimeValueLabel = [[JLMultipartLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles flightDataValueStyle],
                                                                            [JLTrackStyles timeUnitLabelStyle],
                                                                            [JLTrackStyles flightDataValueStyle],
                                                                            [JLTrackStyles timeUnitLabelStyle], nil] 
                                                                     frame:DRIVING_TIME_VALUE_FRAME];
    _drivingTimeValueLabel.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero], 
                                      [NSValue valueWithCGSize:TIME_UNIT_OFFSET], 
                                      [NSValue valueWithCGSize:CGSizeMake(6.0f, 0.0f)],
                                      [NSValue valueWithCGSize:TIME_UNIT_OFFSET], nil];
    _drivingTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _drivingTimeValueLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the bag claim label
    _bagClaimLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:DRIVING_TIME_LABEL_FRAME];
    _bagClaimLabel.text = NSLocalizedString(@"BAG CLAIM", @"BAG CLAIM");
    _bagClaimValueLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle] frame:DRIVING_TIME_VALUE_FRAME];
    _bagClaimValueLabel.text = [self bagClaimValue];
    _bagClaimLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _bagClaimValueLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Create the directions button
    _directionsButton = [[JLButton alloc] initWithButtonStyle:[JLTrackStyles directionsButtonStyle] frame:DIRECTIONS_BUTTON_FRAME];
    [_directionsButton addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    _directionsButton.hidden = YES;
    _directionsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Create the gauge
    _leaveMeter = [[JLLeaveMeter alloc] initWithFrame:LEAVE_IN_GAUGE_FRAME];
    _leaveMeter.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    if (_trackedFlight.leaveForAirportTime) {
        _leaveMeter.timeRemaining = [_trackedFlight.leaveForAirportTime timeIntervalSinceNow];
    }
    
    [self showDrivingTimeOrBagClaim];
    [self setStatus:_trackedFlight.status];
    
    // Add them to the view
    [self.view addSubview:_footerBackground];
    [self.view addSubview:_headerBackground];
    [self.view addSubview:_lookupButton];
    [self.view addSubview:_statusLabel];
    [self.view addSubview:_arrowView];
    [self.view addSubview:_originCityLabel];
    [self.view addSubview:_originCodeLabel];
    [self.view addSubview:_destinationCityLabel];
    [self.view addSubview:_destinationCodeLabel];
    [self.view addSubview:_flightProgressView];
    [self.view addSubview:_landsAtLabel];
    [self.view addSubview:_landsAtTimeLabel];
    [self.view addSubview:_landsInLabel];
    [self.view addSubview:_landsInTimeLabel];
    [self.view addSubview:_terminalLabel];
    [self.view addSubview:_terminalValueLabel];
    [self.view addSubview:_gateLabel];
    [self.view addSubview:_gateValueLabel];
    [self.view addSubview:_drivingTimeLabel];
    [self.view addSubview:_drivingTimeValueLabel];
    [self.view addSubview:_bagClaimLabel];
    [self.view addSubview:_bagClaimValueLabel];
    [self.view addSubview:_leaveMeter];
    [self.view addSubview:_directionsButton];
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
    self._landsInLabel = nil;
    self._landsInTimeLabel = nil;
    self._terminalLabel = nil;
    self._terminalValueLabel = nil;
    self._gateLabel = nil;
    self._gateValueLabel = nil;
    self._drivingTimeLabel = nil;
    self._drivingTimeValueLabel = nil;
    self._bagClaimLabel = nil;
    self._bagClaimValueLabel = nil;
    self._arrowView = nil;
    self._headerBackground = nil;
    self._footerBackground = nil;
    self._lookupButton = nil;
    self._directionsButton = nil;
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
                          

- (NSArray *)landsAtTimeParts {
    NSString *timeString;
    
    if ([_trackedFlight actualArrivalTime]) {
        timeString = [NSDate naturalTimeStringFromDate:[_trackedFlight actualArrivalTime]];
    }
    else {
        timeString = [NSDate naturalTimeStringFromDate:[_trackedFlight estimatedArrivalTime]];
    }
    
    timeString = [timeString stringByAppendingFormat:@" %@", [[NSTimeZone localTimeZone] abbreviation]];
    return [timeString componentsSeparatedByString:@" "];
}


- (NSArray *)landsAtTimeOffsets {
    NSArray *parts = [self landsAtTimeParts];
    NSString *amOrPm = [parts objectAtIndex:1]; // Reliable harcoded index for PM/AM
    CGSize amPmSize = [amOrPm sizeWithFont:[[[JLTrackStyles timeUnitLabelStyle] textStyle] font]];
    return [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero], [NSValue valueWithCGSize:TIME_UNIT_OFFSET_ALT], [NSValue valueWithCGSize:CGSizeMake(TIMEZONE_OFFSET.width - amPmSize.width, TIMEZONE_OFFSET.height)], nil];
}


- (NSString *)landsInLabelText {
    if ([[_trackedFlight estimatedArrivalTime] timeIntervalSinceNow] < 0.0) {
        return NSLocalizedString(@"LANDING", @"LANDING");
    }
    else {
        return NSLocalizedString(@"LANDS IN", @"LANDS IN");
    }
}


- (NSArray *)landsInTimeParts {
    NSTimeInterval landsIn = [[_trackedFlight estimatedArrivalTime] timeIntervalSinceNow];
    
    if (landsIn < 0.0) {
        return [NSArray arrayWithObjects:NSLocalizedString(@"NOW", @"NOW"), @"", nil];
    }
    else {
        NSString *landsInString = [NSDate timeIntervalToShortUnitString:landsIn leadingZeros:NO];
        NSArray *parts = [landsInString componentsSeparatedByString:@" "];
        
        if ([parts count] > 4) {
            parts = [parts subarrayWithRange:NSMakeRange(0, 4)];
        }
        
        return parts;
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


- (NSString *)gateLabelText {
    return NSLocalizedString(@"GATE", @"GATE");
}


- (NSString *)gateValue {
    if (_trackedFlight.destination && [_trackedFlight.destination.gate length] > 0) {
        return [_trackedFlight.destination.gate uppercaseString];
    }
    else {
        return [self blankValue];
    }
}


- (NSArray *)drivingTimeParts {
    NSString *drivingTime = [NSDate timeIntervalToShortUnitString:_trackedFlight.drivingTime leadingZeros:NO];
    NSArray *drivingTimeParts = [drivingTime componentsSeparatedByString:@" "];
    
    if ([drivingTimeParts count] > 4) {
        drivingTimeParts = [drivingTimeParts subarrayWithRange:NSMakeRange(0, 4)];
    }
    
    return drivingTimeParts;
}


- (NSString *)bagClaimValue {
    if (_trackedFlight.destination.bagClaim && [_trackedFlight.destination.bagClaim length] > 0) {
        return _trackedFlight.destination.bagClaim;
    }
    else {
        return [self blankValue];
    }
}


- (NSString *)blankValue {
    return @"--";
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
    
    // Indicate that we don't have location if we were supposed to be able to use it
    if ([[JustLandedSession sharedSession] locationServicesAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your Location Unknown", @"Your Location Unknown")
                                                        message:NSLocalizedString(@"Without your location Just Landed cannot give estimates of when you should leave for the airport. Please check your device's reception and try again.", @"Location unavailable warning.")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void)triedToRegisterForRemoteNotifications:(NSNotification *)notification {
    [self trackFlightWithLocation:[[JustLandedSession sharedSession] lastKnownLocation]];
}


- (void)willTrackFlight:(NSNotification *)notification {
    [self startUpdating];
}


- (void)didTrackFlight:(NSNotification *)notification {    
    // Stop loading animation
    self._showingValidData = YES;
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
    _landsAtTimeLabel.parts = [self landsAtTimeParts];
    _landsInLabel.text = [self landsInLabelText];
    _landsInTimeLabel.parts = [self landsInTimeParts];
    _terminalLabel.text = [self terminalLabelText];
    _terminalValueLabel.text = [self terminalValue];
    _gateLabel.text = [self gateLabelText];
    _gateValueLabel.text = [self gateValue];
    _bagClaimValueLabel.text = [self bagClaimValue];
    
    if (_trackedFlight.leaveForAirportTime && _trackedFlight.drivingTime > 0.0) {
        self._leaveMeter.showEmptyMeter = NO;
        self._leaveMeter.timeRemaining = [_trackedFlight.leaveForAirportTime timeIntervalSinceNow];
    }
    else {
        self._leaveMeter.showEmptyMeter = YES;
    }
    
    // Hide the directions button and driving time if appropriate
    [self showDrivingTimeOrBagClaim];
    
    // Ask them to rate after a few seconds, if eligible
    [[JustLandedSession sharedSession] performSelector:@selector(showRatingRequestIfEligible) 
                                            withObject:nil 
                                            afterDelay:4.0];

    if (!_updateTimer || ![_updateTimer isValid]) {
        self._updateTimer = [NSTimer timerWithTimeInterval:1.0 
                                                             target:self 
                                                           selector:@selector(updateDisplayedData)
                                                           userInfo:nil 
                                                            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
    }
    
    if (!_alternatingLabelTimer || ![_alternatingLabelTimer isValid]) {
        self._alternatingLabelTimer = [NSTimer timerWithTimeInterval:4.0 
                                                              target:self 
                                                            selector:@selector(alternateData)
                                                            userInfo:nil 
                                                             repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_alternatingLabelTimer forMode:NSRunLoopCommonModes];
        [self._alternatingLabelTimer fire];
    }
}


- (void)flightTrackFailed:(NSNotification *)notification {    
    // Stop loading animation
    [self stopUpdating];
    
    FlightTrackFailedReason reason = [[[notification userInfo] valueForKey:FlightTrackFailedReasonKey] intValue];
    
    switch (reason) {
        case TrackFailureFlightNotFound:
        case TrackFailureInvalidFlightNumber:
        case TrackFailureOldFlight: {
            // Old flight, not found flight, invalid flight is not recoverable, go back to lookup interface
            [self stopTrackingUserInitiated:NO];
            break;
        }
        case TrackFailureNoConnection: {
            // No connection
            if (![_trackedFlight isDataFresh] || !_showingValidData) { // Only show no connection if the data is old
                if (!_noConnectionOverlay) {
                    _noConnectionOverlay = [[JLNoConnectionView alloc] initWithFrame:self.view.bounds];
                    _noConnectionOverlay.delegate = self;
                }
                _noConnectionOverlay.tryAgainbutton.enabled = YES;
                
                [self.view addSubview:_noConnectionOverlay];
            }
            break;
        }
        default: {
            // Error or outage
            if (![_trackedFlight isDataFresh] || !_showingValidData) { // Only show 500 if data is old or no data
                if (!_serverErrorOverlay) {
                    _serverErrorOverlay = [[JLServerErrorView alloc] initWithFrame:self.view.bounds 
                                                                         errorType:ERROR_500];
                    _serverErrorOverlay.delegate = self;
                }
                _serverErrorOverlay.tryAgainbutton.enabled = YES;
                
                if (reason == TrackFailureOutage) {
                    _serverErrorOverlay.errorType = ERROR_503;
                }
                else {
                    _serverErrorOverlay.errorType = ERROR_500;
                }
                
                [self.view addSubview:_serverErrorOverlay];
            }
            break;
        }
    }
}


- (void)updateDisplayedData {
    // Update data that needs to be refreshed periodically
    [_statusLabel setText:[self labelForStatus:_trackedFlight.status]];
    _flightProgressView.progress = [_trackedFlight currentProgress];
    _landsInLabel.text = [self landsInLabelText];
    _landsInTimeLabel.parts = [self landsInTimeParts];
    
    if (_trackedFlight.leaveForAirportTime) {
        self._leaveMeter.timeRemaining = [_trackedFlight.leaveForAirportTime timeIntervalSinceNow];
    }
    
}


- (void)showDrivingTimeOrBagClaim {
    if (_trackedFlight.drivingTime > 0.0 && _trackedFlight.leaveForAirportTime) {
        _drivingTimeValueLabel.parts = [self drivingTimeParts];
        _drivingTimeLabel.hidden = NO;
        _drivingTimeValueLabel.hidden = NO;
        _bagClaimLabel.hidden = YES;
        _bagClaimValueLabel.hidden = YES;
        
        if (_trackedFlight.destination.location) {
            _directionsButton.hidden = NO; 
        }
        else {
            _directionsButton.hidden = YES; 
        }
    }
    else {
        _drivingTimeLabel.hidden = YES;
        _drivingTimeValueLabel.hidden = YES;
        _directionsButton.hidden = YES; 
        
        if (_trackedFlight.drivingTime == 0.0 && _trackedFlight.destination.bagClaim && [_trackedFlight.destination.bagClaim length] > 0) {
            _bagClaimLabel.hidden = NO;
            _bagClaimValueLabel.hidden = NO;
        }
        else {
            _bagClaimLabel.hidden = YES;
            _bagClaimValueLabel.hidden = YES;
        }
    }
}


- (void)alternateData {
    // Show lands in only during the last hour of the flight
    BOOL showLandsIn = [_trackedFlight status] != LANDED && [[_trackedFlight estimatedArrivalTime] timeIntervalSinceNow] < 3600.0;
    BOOL showGate = _trackedFlight.destination && [_trackedFlight.destination.gate length] > 0;
    BOOL showTerminal = _trackedFlight.destination.terminal && [_trackedFlight.destination.terminal length] > 0;
    
    // Transition from lands at to lands in
    if (showLandsIn && (_landsInLabel.alpha < 1.0f || _landsAtLabel.alpha > 0.0f)) { // Only animate if needed
        [self fadeOut:_landsAtLabel fadeIn:_landsInLabel];
        [self fadeOut:_landsAtTimeLabel fadeIn:_landsInTimeLabel];
    }
    
    // Transition from lands in to lands at
    else if (_landsAtLabel.alpha < 1.0f || _landsInLabel.alpha > 0.0f) { // Only do it if needed
            [self fadeOut:_landsInLabel fadeIn:_landsAtLabel];
            [self fadeOut:_landsInTimeLabel fadeIn:_landsAtTimeLabel];
    }
    
    // Transition from terminal to gate
    if (showGate && (_gateLabel.alpha < 1.0f || _terminalLabel.alpha > 0.0f)) { // Only animate if needed
        [self fadeOut:_terminalLabel fadeIn:_gateLabel];
        [self fadeOut:_terminalValueLabel fadeIn:_gateValueLabel];
    }
            
    // Transition from gate to terminal
    else if (showTerminal && (_terminalLabel.alpha < 1.0f || _gateLabel.alpha > 0.0f)) { // Only do it if needed
        [self fadeOut:_gateLabel fadeIn:_terminalLabel];
        [self fadeOut:_gateValueLabel fadeIn:_terminalValueLabel];
    }
}


- (void)fadeOut:(UIView *)aView fadeIn:(UIView *)anotherView {
    anotherView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         aView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         anotherView.alpha = 0.0f;
                         [UIView animateWithDuration:0.5 
                                          animations:^{
                                              anotherView.alpha = 1.0f;
                                          }];
                     }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NoConnectionDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tryConnectionAgain {
    [self refresh];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)backToLookup {
    [self stopTrackingUserInitiated:YES];
}


- (void)showMap {
    // Trigger getting the location
    CLLocationManager *locMgr = [[CLLocationManager alloc] init];
    locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    [locMgr startUpdatingLocation];
    
    NSString *mapURL = nil;
    NSString *destName = (_trackedFlight.destination.iataCode) ? _trackedFlight.destination.iataCode : 
                                                                 _trackedFlight.destination.icaoCode;
    destName = [destName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *origLoc = @"Current+Location";
    NSString *destLoc = [NSString stringWithFormat:@"%f,%f", 
                         _trackedFlight.destination.location.coordinate.latitude,
                         _trackedFlight.destination.location.coordinate.longitude];
    
    mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@&layer=t&t=m",
              origLoc, [NSString stringWithFormat:@"%@@%@", destName, destLoc]];

    [FlurryAnalytics logEvent:FY_GOT_DIRECTIONS];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURL]];
    [locMgr stopUpdatingLocation];
}


- (void)refresh {
    CLLocation *location = [[JustLandedSession sharedSession] lastKnownLocation];
    
    if (location) {
        // We already have a location (it may be stale), track now
        [self trackFlightWithLocation:location];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_updateTimer invalidate];
    [_alternatingLabelTimer invalidate];
    _noConnectionOverlay.delegate = nil;
    _serverErrorOverlay.delegate = nil;
}

@end
