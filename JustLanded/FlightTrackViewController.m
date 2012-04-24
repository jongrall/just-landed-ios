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
@property (strong, nonatomic) UIImageView *_arrowView;
@property (strong, nonatomic) UIImageView *_headerBackground;
@property (strong, nonatomic) UIImageView *_footerBackground;
@property (strong, nonatomic) JLLookupButton *_lookupButton;
@property (strong, nonatomic) JLButton *_directionsButton;
@property (strong, nonatomic) JLLeaveMeter *_leaveMeter;
@property (nonatomic) BOOL _showingPrimaryData;

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
- (void)setFlightNumber:(NSString *)fnum;
- (void)setStatus:(FlightStatus)newStatus;
- (NSString *)landsAtLabelText;
- (NSArray *)landsAtTimeParts;
- (NSString *)landsInLabelText;
- (NSArray *)landsInTimeParts;
- (NSString *)terminalLabelText;
- (NSString *)terminalValue;
- (NSString *)gateLabelText;
- (NSString *)gateValue;
- (NSArray *)drivingTimeParts;
- (NSString *)blankValue;
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
@synthesize _arrowView;
@synthesize _headerBackground;
@synthesize _footerBackground;
@synthesize _lookupButton;
@synthesize _directionsButton;
@synthesize _leaveMeter;
@synthesize _showingPrimaryData;


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
                NSLog(@"%f", earlyAmt);
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
        NSAssert((aFlight != nil), @"Flight to track is nil!");
        _trackedFlight = aFlight;
        
        // First timer tick should show primary data
        _showingPrimaryData = YES;
        
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
                                                 selector:@selector(refresh) 
                                                     name:UIApplicationWillEnterForegroundNotification 
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


- (void)startUpdating {
    
}


- (void)stopUpdating {
    
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
    _headerBackground = [[UIImageView alloc] initWithFrame:TRACK_HEADER_FRAME];
                         
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
    _landsAtTimeLabel.parts = [self landsAtTimeParts];
    _landsAtTimeLabel.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero], [NSValue valueWithCGSize:TIME_UNIT_OFFSET], nil];
    
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
    
    // Add the terminal info
    _terminalLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:TERMINAL_LABEL_FRAME];
    _terminalLabel.text = [self terminalLabelText];
    _terminalValueLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle] frame:TERMINAL_VALUE_FRAME];
    _terminalValueLabel.text = [self terminalValue];
    
    // Add the gate info
    _gateLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle] frame:TERMINAL_LABEL_FRAME];
    _gateLabel.text = [self gateLabelText];
    _gateValueLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle] frame:TERMINAL_VALUE_FRAME];
    _gateValueLabel.text = [self gateValue];
    _gateLabel.alpha = 0.0f;
    _gateValueLabel.alpha = 0.0f;
    
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
    
    // Create the directions button
    _directionsButton = [[JLButton alloc] initWithButtonStyle:[JLTrackStyles directionsButtonStyle] frame:DIRECTIONS_BUTTON_FRAME];
    [_directionsButton addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    _directionsButton.hidden = YES;
    
    // Create the gauge
    _leaveMeter = [[JLLeaveMeter alloc] initWithFrame:LEAVE_IN_GAUGE_FRAME];
    
    if (_trackedFlight.leaveForAirportTime) {
        _leaveMeter.timeRemaining = [_trackedFlight.leaveForAirportTime timeIntervalSinceNow];
    }
    
    if (_trackedFlight.drivingTime) {
        _drivingTimeValueLabel.parts = [self drivingTimeParts];
        _drivingTimeLabel.hidden = NO;
        _drivingTimeValueLabel.hidden = NO;
    
        if (_trackedFlight.destination.location) {
            _directionsButton.hidden = NO; 
        }
    }
    else {
        _drivingTimeLabel.hidden = YES;
        _drivingTimeValueLabel.hidden = YES;
    }
    
    [self setStatus:_trackedFlight.status];
    
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
    [self.view addSubview:_landsInLabel];
    [self.view addSubview:_landsInTimeLabel];
    [self.view addSubview:_terminalLabel];
    [self.view addSubview:_terminalValueLabel];
    [self.view addSubview:_gateLabel];
    [self.view addSubview:_gateValueLabel];
    [self.view addSubview:_drivingTimeLabel];
    [self.view addSubview:_drivingTimeValueLabel];
    [self.view addSubview:_destinationCityLabel];
    [self.view addSubview:_directionsButton];
    [self.view addSubview:_leaveMeter];
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
    
    // Optimization: if the flight is landed or canceled, stop location services
    if (newStatus == LANDED || newStatus == CANCELED) {
        [[JustLandedSession sharedSession] stopLocationServices];
    }
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
                 
    return [timeString componentsSeparatedByString:@" "];
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
    if (_trackedFlight.destination.gate && [_trackedFlight.destination.gate length] > 0) {
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
    
    // TODO: Indicate that we don't have location
}


- (void)triedToRegisterForRemoteNotifications:(NSNotification *)notification {
    [self trackFlightWithLocation:[[JustLandedSession sharedSession] lastKnownLocation]];
}


- (void)willTrackFlight:(NSNotification *)notification {
    [self startUpdating];
}


- (void)didTrackFlight:(NSNotification *)notification {
    [_updateTimer invalidate];
    [_alternatingLabelTimer invalidate];
    
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
    _landsAtTimeLabel.parts = [self landsAtTimeParts];
    _landsInLabel.text = [self landsInLabelText];
    _landsInTimeLabel.parts = [self landsInTimeParts];
    _terminalLabel.text = [self terminalLabelText];
    _terminalValueLabel.text = [self terminalValue];
    _gateLabel.text = [self gateLabelText];
    _gateValueLabel.text = [self gateValue];
    
    BOOL showGate = _trackedFlight.destination.gate && [_trackedFlight.destination.gate length] > 0;
    BOOL showTerminal = _trackedFlight.destination.terminal && [_trackedFlight.destination.terminal length] > 0;
    
    if (!showGate && !showTerminal) { // Always show at least terminal
        _terminalLabel.alpha = 1.0f;
        _terminalValueLabel.alpha = 1.0f;
        _gateLabel.alpha = 0.0f;
        _gateValueLabel.alpha = 0.0f;
        _showingPrimaryData = YES;
    }
    else {
        _terminalLabel.alpha = (showTerminal) ? 1.0f : 0.0f;
        _terminalValueLabel.alpha = (showTerminal) ? 1.0f : 0.0f;
        _gateLabel.alpha = (!showTerminal && showGate) ? 1.0f : 0.0f;
        _gateValueLabel.alpha = (!showTerminal && showGate) ? 1.0f : 0.0f;
        _showingPrimaryData = showTerminal;
    }
    
    if (_trackedFlight.leaveForAirportTime) {
        self._leaveMeter.showEmptyMeter = NO;
        self._leaveMeter.timeRemaining = [_trackedFlight.leaveForAirportTime timeIntervalSinceNow];
    }
    else {
        self._leaveMeter.showEmptyMeter = YES;
    }
    
    // Hide the directions button and driving time if appropriate
    if (_trackedFlight.leaveForAirportTime) {
        self._directionsButton.hidden = NO;
        self._drivingTimeLabel.hidden = NO;
        self._drivingTimeValueLabel.parts = [self drivingTimeParts];
        self._drivingTimeValueLabel.hidden = NO;
    }
    else {
        self._directionsButton.hidden = YES;
        self._drivingTimeLabel.hidden = YES;
        self._drivingTimeValueLabel.hidden = YES;
    }
    
    // Ask them to rate after a few seconds, if eligible
    [[JustLandedSession sharedSession] performSelector:@selector(showRatingRequestIfEligible) 
                                            withObject:nil 
                                            afterDelay:4.0];
    
    if (!_updateTimer || ![_updateTimer isValid]) {
        self._updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                             target:self 
                                                           selector:@selector(updateDisplayedData)
                                                           userInfo:nil 
                                                            repeats:YES];
    }
    
    if (!_alternatingLabelTimer || ![_alternatingLabelTimer isValid]) {
        self._alternatingLabelTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 
                                                                       target:self 
                                                                     selector:@selector(alternateData)
                                                                     userInfo:nil 
                                                                      repeats:YES];
    }
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


- (void)alternateData {
    // Show lands in only during the last hour of the flight
    BOOL showLandsIn = [_trackedFlight status] != LANDED && [[_trackedFlight estimatedArrivalTime] timeIntervalSinceNow] < 3600.0;
    BOOL showGate = _trackedFlight.destination.gate && [_trackedFlight.destination.gate length] > 0;
    BOOL showTerminal = _trackedFlight.destination.terminal && [_trackedFlight.destination.terminal length] > 0;
    
    if (_showingPrimaryData) {
        if (showLandsIn && _landsInLabel.alpha == 0.0f) { // Only animate if needed
            // Transition from lands at to lands in
            [self fadeOut:_landsAtLabel fadeIn:_landsInLabel];
            [self fadeOut:_landsAtTimeLabel fadeIn:_landsInTimeLabel];
        }
        if (showGate && _gateLabel.alpha == 0.0f) { // Only animate if needed
            // Transition from terminal to gate
            [self fadeOut:_terminalLabel fadeIn:_gateLabel];
            [self fadeOut:_terminalValueLabel fadeIn:_gateValueLabel];
        }
        
        _showingPrimaryData = NO;
    }
    else {
        // Transition from lands in to lands at
        if (_landsAtLabel.alpha == 0.0f) { // Only do it if needed
            [self fadeOut:_landsInLabel fadeIn:_landsAtLabel];
            [self fadeOut:_landsInTimeLabel fadeIn:_landsAtTimeLabel];
        }
        // Transition from gate to terminal
        if (showTerminal && _terminalLabel.alpha == 0.0f) { // Only do it if needed
            [self fadeOut:_gateLabel fadeIn:_terminalLabel];
            [self fadeOut:_gateValueLabel fadeIn:_terminalValueLabel];
        }
        
        _showingPrimaryData = YES;
    }
}


- (void)fadeOut:(UIView *)aView fadeIn:(UIView *)anotherView {
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
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)stopTracking {
    [_updateTimer invalidate];
    [_alternatingLabelTimer invalidate];
    [self stopUpdating];
    [_trackedFlight stopTracking];
    [self.delegate didFinishTracking:self userInitiated:YES];
}


- (void)showMap {
    // Trigger getting the location
    [[JustLandedSession sharedSession] lastKnownLocation];
    
    NSString *mapURL = nil;
    NSString *destName = (_trackedFlight.destination.iataCode) ? _trackedFlight.destination.iataCode : 
                                                                 _trackedFlight.destination.icaoCode;
    destName = [destName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *destLoc = [NSString stringWithFormat:@"%f,%f", 
                         _trackedFlight.destination.location.coordinate.latitude,
                         _trackedFlight.destination.location.coordinate.longitude];
    
    mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@&layer=t&t=m",
              @"Current%20Location", [NSString stringWithFormat:@"%@@%@", destName, destLoc]];

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [_flightProgressView stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
