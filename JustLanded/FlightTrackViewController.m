//
//  FlightTrackViewController.m
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "FlightTrackViewController.h"
#import "AboutViewController.h"
#import "WebContentViewController.h"
#import "JustLandedSession.h"
#import "Flight.h"
#import "FlurryAnalytics.h"
#import "AppDelegate.h"
#import "JLMessageComposeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Availability.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
    WarningTypeNone = 8008,
    WarningTypeDisabledLocationServices,
    WarningTypeDeniedLocationServices,
    WarningTypeRestrictedLocationServices,
    WarningTypeDisallowedNotifications,
    WarningTypeTooFarFromDestination,
} LeaveForAirportWarningType;

NSUInteger const TextUponArrivalAlertTag = 65009;

@interface FlightTrackViewController() <NoConnectionDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) Flight *trackedFlight_;
@property (strong, nonatomic) CLLocationManager *locationManager_;
@property (strong, nonatomic) NSTimer *updateTimer_;
@property (strong, nonatomic) NSTimer *alternatingLabelTimer_;
@property (strong, nonatomic) NSMutableArray *ignoredWarnings_;
@property (nonatomic) BOOL showingValidData_;
@property (nonatomic) BOOL hasBeenToAirport_;
@property (nonatomic) BOOL hasBeenNotifiedToText_;

// UI Properties
@property (strong, nonatomic) JLStatusLabel *statusLabel_;
@property (strong, nonatomic) JLStatusLabel *originCodeLabel_;
@property (strong, nonatomic) JLStatusLabel *originCityLabel_;
@property (strong, nonatomic) JLStatusLabel *destinationCodeLabel_;
@property (strong, nonatomic) JLStatusLabel *destinationCityLabel_;
@property (strong, nonatomic) JLFlightProgressView *flightProgressView_;
@property (strong, nonatomic) JLLabel *landsAtLabel_;
@property (strong, nonatomic) JLMultipartLabel *landsAtTimeLabel_;
@property (strong, nonatomic) JLLabel *landsInLabel_;
@property (strong, nonatomic) JLMultipartLabel *landsInTimeLabel_;
@property (strong, nonatomic) JLLabel *terminalLabel_;
@property (strong, nonatomic) JLLabel *terminalValueLabel_;
@property (strong, nonatomic) JLLabel *gateLabel_;
@property (strong, nonatomic) JLLabel *gateValueLabel_;
@property (strong, nonatomic) JLLabel *drivingTimeLabel_;
@property (strong, nonatomic) JLMultipartLabel *drivingTimeValueLabel_;
@property (strong, nonatomic) JLLabel *bagClaimLabel_;
@property (strong, nonatomic) JLLabel *bagClaimValueLabel_;
@property (strong, nonatomic) UIImageView *arrowView_;
@property (strong, nonatomic) UIImageView *headerBackground_;
@property (strong, nonatomic) UIImageView *footerBackground_;
@property (strong, nonatomic) JLLookupButton *lookupButton_;
@property (strong, nonatomic) JLButton *warningButton_;
@property (strong, nonatomic) JLButton *directionsButton_;
@property (strong, nonatomic) JLLeaveMeter *leaveMeter_;
@property (strong, nonatomic) JLNoConnectionView *noConnectionOverlay_;
@property (strong, nonatomic) JLServerErrorView *serverErrorOverlay_;
@property (strong, nonatomic) JLLoadingView *loadingOverlay_;


// Display helper methods
+ (UIImage *)arrowImageForStatus:(FlightStatus)status;
+ (UIImage *)headerBackgroundImageForStatus:(FlightStatus)status;
- (NSTimeZone *)displayTimezone;
- (NSString *)labelForStatus:(FlightStatus)status;
- (void)setFlightNumber:(NSString *)fnum;
- (void)setStatus:(FlightStatus)newStatus;
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
- (void)invalidateData;
- (void)indicateUpdating;
- (void)indicateFinishedUpdating;
- (void)updateDisplayedData;
- (LeaveForAirportWarningType)warningToDisplay;
- (void)showDrivingTimeOrBagClaim;
- (void)alternateData;
- (void)fadeOut:(UIView *)aView fadeIn:(UIView *)anotherView;
- (BOOL)isAtAirport;
- (void)composeTextOnAirportArrival;

// Update methods
- (void)stopTrackingUserInitiated:(BOOL)userInitiated;
- (void)willTrackFlight:(NSNotification *)notification;
- (void)didTrackFlight:(NSNotification *)notification;
- (void)flightTrackFailed:(NSNotification *)notification;

// Getting location
- (BOOL)isLocationAcceptable:(CLLocation *)loc;

// Button Actions
- (void)backToLookup;
- (void)showMap;
- (void)showWarning;

// Bg task cleanup
- (void)finishWakeupTrackTask;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FlightTrackViewController

@synthesize trackedFlight_;
@synthesize locationManager_;
@synthesize updateTimer_;
@synthesize alternatingLabelTimer_;
@synthesize ignoredWarnings_;
@synthesize hasBeenToAirport_;
@synthesize hasBeenNotifiedToText_;
@synthesize noConnectionOverlay_;
@synthesize serverErrorOverlay_;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (id)initWithFlight:(Flight *)aFlight {
    self = [super init];
    
    if (self) {
        NSAssert(aFlight != nil, @"Flight to track is nil!");
        trackedFlight_ = aFlight;
        
        // Create a location manager
        locationManager_ = [[CLLocationManager alloc] init];
		locationManager_.delegate = self;
		locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager_.distanceFilter = LOCATION_DISTANCE_FILTER;
        if ([locationManager_ respondsToSelector:@selector(setPurpose:)]) {
            // Deprecated but desired API
            locationManager_.purpose = NSLocalizedString(@"This lets us estimate your driving time to the airport.",
                                                              @"Location Purpose");
        }
        
        ignoredWarnings_ = [[NSMutableArray alloc] init];
        hasBeenToAirport_ = NO;
        hasBeenNotifiedToText_ = NO;
        
        // Listen for update notifications for the Flight to trigger UI indicators
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willTrackFlight:)
                                                     name:WillTrackFlightNotification
                                                   object:trackedFlight_];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didTrackFlight:)
                                                     name:DidTrackFlightNotification
                                                   object:trackedFlight_];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flightTrackFailed:)
                                                     name:FlightTrackFailedNotification
                                                   object:trackedFlight_];
        
        // Track on push token update / failure
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(track)
                                                     name:DidUpdatePushTokenNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(track)
                                                     name:DidFailToUpdatePushTokenNotification
                                                   object:[UIApplication sharedApplication]];
        
        
        // Track on resume
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(track)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        // When going to the background, cover the screen with loading
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(invalidateData)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        [self indicateUpdating];
        
        // Track the flight if we've already tried to get the push token
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.triedToRegisterForRemoteNotifications) { // We already tried to get the push token
            [self track];
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    // Set up the main view
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                screenBounds.size.width,
                                                                screenBounds.size.height - 20.0f)]; // Status bar
    [mainView setBackgroundColor:[UIColor blackColor]];
    self.view = mainView;
    
    // Create the footer background
    self.footerBackground_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracking_footer_bg"]];
    [self.footerBackground_ setFrame:[JLTrackStyles trackFooterFrame]];
    self.footerBackground_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Create the header background
    self.headerBackground_ = [[UIImageView alloc] initWithFrame:[JLTrackStyles trackHeaderFrame]];
    
    // Create the lookup button
    self.lookupButton_ = [[JLLookupButton alloc] initWithButtonStyle:[JLTrackStyles lookupButtonStyle] frame:CGRectZero status:self.trackedFlight_.status];
    [self.lookupButton_ addTarget:self action:@selector(backToLookup) forControlEvents:UIControlEventTouchUpInside];
    [self setFlightNumber:self.trackedFlight_.flightNumber];
    
    // Create the status label
    self.statusLabel_ = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles statusLabelStyle]
                                                            frame:[JLTrackStyles statusLabelFrame]
                                                           status:self.trackedFlight_.status];
    
    //Create the arrow view
    UIImage *arrowImage = [[self class] arrowImageForStatus:self.trackedFlight_.status];
    CGPoint arrowOrigin = [JLTrackStyles arrowOrigin];
    self.arrowView_ = [[UIImageView alloc] initWithFrame:CGRectMake(arrowOrigin.x,
                                                                    arrowOrigin.y,
                                                                    arrowImage.size.width,
                                                                    arrowImage.size.height)];
    [self.arrowView_ setImage:arrowImage];
    
    // Create the airport code labels
    self.originCodeLabel_ = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles airportCodeStyle]
                                                                frame:[JLTrackStyles originCodeLabelFrame]
                                                               status:self.trackedFlight_.status];
    self.originCodeLabel_.text = [self.trackedFlight_.origin bestAirportCode];
    
    self.destinationCodeLabel_ = [[JLStatusLabel alloc]  initWithLabelStyle:[JLTrackStyles airportCodeStyle]
                                                                      frame:[JLTrackStyles destinationCodeLabelFrame]
                                                                     status:self.trackedFlight_.status];
    
    self.destinationCodeLabel_.text = [self.trackedFlight_.destination bestAirportCode];
    
    // Create the city labels
    self.originCityLabel_ = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles cityNameStyle]
                                                                frame:[JLTrackStyles originCityLabelFrame]
                                                               status:self.trackedFlight_.status];
    
    self.originCityLabel_.text = [self.trackedFlight_.origin.city uppercaseString];
    self.destinationCityLabel_ = [[JLStatusLabel alloc] initWithLabelStyle:[JLTrackStyles cityNameStyle]
                                                                     frame:[JLTrackStyles destinationCityLabelFrame]
                                                                    status:self.trackedFlight_.status];
    
    self.destinationCityLabel_.text = [self.trackedFlight_.destination.city uppercaseString];
    
    // Add the flight progress view
    self.flightProgressView_ = [[JLFlightProgressView alloc] initWithFrame:[JLTrackStyles flightProgressFrame]
                                                                  progress:[self.trackedFlight_ currentProgress]
                                                                 timeOfDay:self.trackedFlight_.timeOfDay
                                                              aircraftType:self.trackedFlight_.aircraftType];
    self.flightProgressView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    // Add the lands at labels
    self.landsAtLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle]
                                                       frame:[JLTrackStyles landsAtLabelFrame]];
    self.landsAtLabel_.text = [self landsAtLabelText];
    self.landsAtTimeLabel_ = [[JLMultipartLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles flightDataValueStyle],
                                                                            [JLTrackStyles timeUnitLabelStyle],
                                                                            [JLTrackStyles timezoneLabelStyle], nil]
                                                                frame:[JLTrackStyles landsAtTimeFrame]];
    self.landsAtTimeLabel_.parts = [self landsAtTimeParts];
    self.landsAtTimeLabel_.offsets = [self landsAtTimeOffsets];
    self.landsAtLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.landsAtTimeLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the lands in labels
    self.landsInLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle]
                                                       frame:[JLTrackStyles landsAtLabelFrame]];
    self.landsInLabel_.text = [self landsInLabelText];
    self.landsInTimeLabel_ = [[JLMultipartLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles flightDataValueStyle],
                                                                            [JLTrackStyles timeUnitLabelStyle],
                                                                            [JLTrackStyles flightDataValueStyle],
                                                                            [JLTrackStyles timeUnitLabelStyle], nil]
                                                                     frame:[JLTrackStyles landsAtTimeFrame]];
    self.landsInTimeLabel_.parts = [self landsInTimeParts];
    CGSize timeUnitOffset = [JLTrackStyles timeUnitOffset];
    self.landsInTimeLabel_.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero],
                                      [NSValue valueWithCGSize:timeUnitOffset],
                                      [NSValue valueWithCGSize:CGSizeMake(6.0f, 0.0f)],
                                      [NSValue valueWithCGSize:timeUnitOffset],nil];
    self.landsInLabel_.alpha = 0.0f;
    self.landsInTimeLabel_.alpha = 0.0f;
    self.landsInLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.landsInTimeLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the terminal info
    self.terminalLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle]
                                                        frame:[JLTrackStyles terminalLabelFrame]];
    self.terminalLabel_.text = [self terminalLabelText];
    self.terminalValueLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle]
                                                             frame:[JLTrackStyles terminalValueFrame]];
    self.terminalValueLabel_.text = [self terminalValue];
    self.terminalLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.terminalValueLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the gate info
    self.gateLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle]
                                                    frame:[JLTrackStyles terminalLabelFrame]];
    self.gateLabel_.text = [self gateLabelText];
    self.gateValueLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle]
                                                         frame:[JLTrackStyles terminalValueFrame]];
    self.gateValueLabel_.text = [self gateValue];
    self.gateLabel_.alpha = 0.0f;
    self.gateValueLabel_.alpha = 0.0f;
    self.gateLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.gateValueLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the driving time info
    self.drivingTimeLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle]
                                                           frame:[JLTrackStyles drivingTimeLabelFrame]];
    self.drivingTimeLabel_.text = NSLocalizedString(@"DRIVING TIME", @"DRIVING TIME");
    self.drivingTimeValueLabel_ = [[JLMultipartLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles flightDataValueStyle],
                                                                                 [JLTrackStyles timeUnitLabelStyle],
                                                                                 [JLTrackStyles flightDataValueStyle],
                                                                                 [JLTrackStyles timeUnitLabelStyle], nil]
                                                                          frame:[JLTrackStyles drivingTimeValueFrame]];
    self.drivingTimeValueLabel_.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero],
                                           [NSValue valueWithCGSize:timeUnitOffset],
                                           [NSValue valueWithCGSize:CGSizeMake(6.0f, 0.0f)],
                                           [NSValue valueWithCGSize:timeUnitOffset], nil];
    self.drivingTimeLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.drivingTimeValueLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Add the bag claim label
    self.bagClaimLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataLabelStyle]
                                                        frame:[JLTrackStyles drivingTimeLabelFrame]];
    self.bagClaimLabel_.text = NSLocalizedString(@"BAG CLAIM", @"BAG CLAIM");
    self.bagClaimValueLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles flightDataValueStyle]
                                                             frame:[JLTrackStyles drivingTimeValueFrame]];
    self.bagClaimValueLabel_.text = [self bagClaimValue];
    self.bagClaimLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.bagClaimValueLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Create the directions button
    self.directionsButton_ = [[JLButton alloc] initWithButtonStyle:[JLTrackStyles directionsButtonStyle]
                                                             frame:[JLTrackStyles directionsButtonFrame]];
    [self.directionsButton_ addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    self.directionsButton_.hidden = YES;
    self.directionsButton_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Create the gauge
    self.leaveMeter_ = [[JLLeaveMeter alloc] initWithFrame:[JLTrackStyles leaveInGaugeFrame]];
    self.leaveMeter_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    if (self.trackedFlight_.leaveForAirportTime) {
        self.leaveMeter_.timeRemaining = [self.trackedFlight_.leaveForAirportTime timeIntervalSinceNow];
    }
    
    // Create the warning button
    self.warningButton_ = [[JLButton alloc] initWithButtonStyle:[JLTrackStyles warningButtonStyle]
                                                          frame:[JLTrackStyles warningButtonFrame]];
    [self.warningButton_ addTarget:self action:@selector(showWarning) forControlEvents:UIControlEventTouchUpInside];
    self.warningButton_.hidden = YES;
    self.warningButton_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self showDrivingTimeOrBagClaim];
    [self setStatus:self.trackedFlight_.status];
    
    // Add them to the view
    [self.view addSubview:self.footerBackground_];
    [self.view addSubview:self.headerBackground_];
    [self.view addSubview:self.lookupButton_];
    [self.view addSubview:self.statusLabel_];
    [self.view addSubview:self.arrowView_];
    [self.view addSubview:self.originCityLabel_];
    [self.view addSubview:self.originCodeLabel_];
    [self.view addSubview:self.destinationCityLabel_];
    [self.view addSubview:self.destinationCodeLabel_];
    [self.view addSubview:self.flightProgressView_];
    [self.view addSubview:self.landsAtLabel_];
    [self.view addSubview:self.landsAtTimeLabel_];
    [self.view addSubview:self.landsInLabel_];
    [self.view addSubview:self.landsInTimeLabel_];
    [self.view addSubview:self.terminalLabel_];
    [self.view addSubview:self.terminalValueLabel_];
    [self.view addSubview:self.gateLabel_];
    [self.view addSubview:self.gateValueLabel_];
    [self.view addSubview:self.drivingTimeLabel_];
    [self.view addSubview:self.drivingTimeValueLabel_];
    [self.view addSubview:self.bagClaimLabel_];
    [self.view addSubview:self.bagClaimValueLabel_];
    [self.view addSubview:self.leaveMeter_];
    [self.view addSubview:self.warningButton_];
    [self.view addSubview:self.directionsButton_];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.statusLabel_ = nil;
    self.originCodeLabel_ = nil;
    self.originCityLabel_ = nil;
    self.destinationCodeLabel_ = nil;
    self.destinationCityLabel_ = nil;
    self.flightProgressView_ = nil;
    self.landsAtLabel_ = nil;
    self.landsAtTimeLabel_ = nil;
    self.landsInLabel_ = nil;
    self.landsInTimeLabel_ = nil;
    self.terminalLabel_ = nil;
    self.terminalValueLabel_ = nil;
    self.gateLabel_ = nil;
    self.gateValueLabel_ = nil;
    self.drivingTimeLabel_ = nil;
    self.drivingTimeValueLabel_ = nil;
    self.bagClaimLabel_ = nil;
    self.bagClaimValueLabel_ = nil;
    self.arrowView_ = nil;
    self.headerBackground_ = nil;
    self.footerBackground_ = nil;
    self.lookupButton_ = nil;
    self.warningButton_ = nil;
    self.directionsButton_ = nil;
    self.leaveMeter_ = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Only supports portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UI Display Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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


- (NSTimeZone *)displayTimezone {
    // The timezone to use for display purposes
    return [NSTimeZone localTimeZone];
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
            NSTimeInterval lateAmt = fabs([self.trackedFlight_.estimatedArrivalTime timeIntervalSinceDate:self.trackedFlight_.scheduledArrivalTime]);
            
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
            if ([[NSDate date] timeIntervalSinceDate:self.trackedFlight_.actualArrivalTime] < 300.0) {
                return NSLocalizedString(@"just landed ", @"Just Landed Label Text"); // Landed in last 5 minutes
            }
            else {
                return NSLocalizedString(@"landed ", @"Landed Label Text");
            }
            break;
        }
        case EARLY: {
            // Calculate how early it is
            NSTimeInterval earlyAmt = fabs([self.trackedFlight_.scheduledArrivalTime timeIntervalSinceDate:self.trackedFlight_.estimatedArrivalTime]);
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

- (void)setFlightNumber:(NSString *)fnum {
    // Update the button title
    [self.lookupButton_ setTitle:fnum forState:UIControlStateNormal];
    
    // Update the button size
    CGSize labelSize = [fnum sizeWithFont:[[[[JLTrackStyles lookupButtonStyle] labelStyle] textStyle] font]];
    UIEdgeInsets labelInsets = [[JLTrackStyles lookupButtonStyle] labelInsets];
    CGPoint lookupButtonOrigin = [JLTrackStyles lookupButtonOrigin];
    [self.lookupButton_ setFrame:CGRectMake(lookupButtonOrigin.x,
                                            lookupButtonOrigin.y,
                                            labelSize.width + labelInsets.left + labelInsets.right,
                                            34.0f)];
}


- (void)setStatus:(FlightStatus)newStatus {
    // Set the background image
    self.headerBackground_.image = [[self class] headerBackgroundImageForStatus:newStatus];
    
    // Update the elements affected by status color
    [self.lookupButton_ setStatus:newStatus];
    [self.statusLabel_ setStatus:newStatus];
    [self.originCodeLabel_ setStatus:newStatus];
    [self.originCityLabel_ setStatus:newStatus];
    [self.destinationCodeLabel_ setStatus:newStatus];
    [self.destinationCityLabel_ setStatus:newStatus];
    
    // Set the status label text
    [self.statusLabel_ setText:[self labelForStatus:newStatus]];
}


- (NSString *)landsAtLabelText {
    if ([self.trackedFlight_ actualArrivalTime]) {
        return [[NSString stringWithFormat:@"LANDED %@ AT", [NSDate naturalDayStringFromDate:self.trackedFlight_.actualArrivalTime withTimezone:[self displayTimezone]]] uppercaseString];
    }
    else {
        return [[NSString stringWithFormat:@"LANDS %@ AT", [NSDate naturalDayStringFromDate:self.trackedFlight_.estimatedArrivalTime withTimezone:[self displayTimezone]]] uppercaseString];
    }
}


- (NSArray *)landsAtTimeParts {
    // Prefer actual arrival time over estimated
    NSDate *landsAtDate = self.trackedFlight_.actualArrivalTime ? self.trackedFlight_.actualArrivalTime : self.trackedFlight_.estimatedArrivalTime;
    NSString *timeString = [NSDate naturalTimeStringFromDate:landsAtDate withTimezone:[self displayTimezone]];
    NSString *tzAbbrev = [[self displayTimezone] abbreviationForDate:landsAtDate];
    NSUInteger MAX_TIMEZONE_LENGTH = 4;
    tzAbbrev = [tzAbbrev length] > MAX_TIMEZONE_LENGTH ? [tzAbbrev substringToIndex:4] : tzAbbrev;
    timeString = [timeString stringByAppendingFormat:@" %@", tzAbbrev];
    return [timeString componentsSeparatedByString:@" "];
}


- (NSArray *)landsAtTimeOffsets {
    NSArray *parts = [self landsAtTimeParts];
    NSString *amOrPm = [parts objectAtIndex:1]; // Reliable harcoded index for PM/AM
    CGSize amPmSize = [amOrPm sizeWithFont:[[[JLTrackStyles timeUnitLabelStyle] textStyle] font]];
    CGSize timezoneOffset = [JLTrackStyles timezoneOffset];
    return [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeZero],
            [NSValue valueWithCGSize:[JLTrackStyles timeUnitOffsetAlt]],
            [NSValue valueWithCGSize:CGSizeMake(timezoneOffset.width - amPmSize.width, timezoneOffset.height)], nil];
}


- (NSString *)landsInLabelText {
    if ([self.trackedFlight_.estimatedArrivalTime timeIntervalSinceNow] < 0.0) {
        return NSLocalizedString(@"LANDING", @"LANDING");
    }
    else {
        return NSLocalizedString(@"LANDS IN", @"LANDS IN");
    }
}


- (NSArray *)landsInTimeParts {
    NSTimeInterval landsIn = [self.trackedFlight_.estimatedArrivalTime timeIntervalSinceNow];
    
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
    if (self.trackedFlight_.destination.terminal && [self.trackedFlight_.destination.terminal length] > 0) {
        if ([self.trackedFlight_.destination.terminal isEqualToString:@"I"]) {
            return NSLocalizedString(@"INT'L", @"International Abbreviated");
        }
        else {
            return [self.trackedFlight_.destination.terminal uppercaseString];
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
    if (self.trackedFlight_.destination && [self.trackedFlight_.destination.gate length] > 0) {
        return [self.trackedFlight_.destination.gate uppercaseString];
    }
    else {
        return [self blankValue];
    }
}


- (NSArray *)drivingTimeParts {
    NSString *drivingTime = [NSDate timeIntervalToShortUnitString:self.trackedFlight_.drivingTime leadingZeros:NO];
    NSArray *drivingTimeParts = [drivingTime componentsSeparatedByString:@" "];
    
    if ([drivingTimeParts count] > 4) {
        drivingTimeParts = [drivingTimeParts subarrayWithRange:NSMakeRange(0, 4)];
    }
    
    return drivingTimeParts;
}


- (NSString *)bagClaimValue {
    if (self.trackedFlight_.destination.bagClaim && [self.trackedFlight_.destination.bagClaim length] > 0) {
        return self.trackedFlight_.destination.bagClaim;
    }
    else {
        return [self blankValue];
    }
}


- (NSString *)blankValue {
    return @"--";
}


- (void)invalidateData {
    // Invalidates that data and covers the screen with loading... so on resume we're showing the right thing.
    self.showingValidData_ = NO;
    [self indicateUpdating];
}


- (void)indicateUpdating {
    [self.lookupButton_ setEnabled:NO];
    [self.noConnectionOverlay_ removeFromSuperview];
    [self.serverErrorOverlay_ removeFromSuperview];
    
    if (!self.showingValidData_ || ![self.trackedFlight_ isDataFresh]) {
        if (!self.loadingOverlay_) {
            self.loadingOverlay_ = [[JLLoadingView alloc] initWithFrame:self.view.bounds];
        }
        
        [self.view addSubview:self.loadingOverlay_];
        [self.loadingOverlay_ startLoading];
    }
}


- (void)indicateFinishedUpdating {
    [self.lookupButton_ setEnabled:YES]; // Disable untrack while tracking (can cause out-of-order bug)
    [self.loadingOverlay_ stopLoading];
    [self.loadingOverlay_ removeFromSuperview];
}


- (void)updateDisplayedData {
    // Update display data that needs to be refreshed periodically
    [self.statusLabel_ setText:[self labelForStatus:self.trackedFlight_.status]];
    self.flightProgressView_.progress = [self.trackedFlight_ currentProgress];
    self.landsInLabel_.text = [self landsInLabelText];
    self.landsInTimeLabel_.parts = [self landsInTimeParts];
    
    if (self.trackedFlight_.leaveForAirportTime) {
        self.leaveMeter_.timeRemaining = [self.trackedFlight_.leaveForAirportTime timeIntervalSinceNow];
    }
    
}


- (LeaveForAirportWarningType)warningToDisplay {
    if (![CLLocationManager locationServicesEnabled]) {
        return WarningTypeDisabledLocationServices;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return WarningTypeDeniedLocationServices;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return WarningTypeRestrictedLocationServices;
    }
    else if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
        return WarningTypeDisallowedNotifications;
    }
    else if (self.locationManager_.location && self.trackedFlight_.destination.location && self.trackedFlight_.drivingTime == -1.0) {
        return WarningTypeTooFarFromDestination;
    }
    else {
        return WarningTypeNone;
    }
}


- (BOOL)isAtAirport {
    return self.trackedFlight_.drivingTime == 0.0;
}


- (void)showDrivingTimeOrBagClaim {
    if (![self isAtAirport] && self.trackedFlight_.leaveForAirportTime) {
        self.drivingTimeValueLabel_.parts = [self drivingTimeParts];
        self.drivingTimeLabel_.hidden = NO;
        self.drivingTimeValueLabel_.hidden = NO;
        self.bagClaimLabel_.hidden = YES;
        self.bagClaimValueLabel_.hidden = YES;
        
        if (self.trackedFlight_.destination.location) {
            self.directionsButton_.hidden = NO;
        }
        else {
            self.directionsButton_.hidden = YES;
        }
    }
    else {
        self.drivingTimeLabel_.hidden = YES;
        self.drivingTimeValueLabel_.hidden = YES;
        self.directionsButton_.hidden = YES;
        
        if ([self isAtAirport] && self.trackedFlight_.destination.bagClaim && [self.trackedFlight_.destination.bagClaim length] > 0) {
            self.bagClaimLabel_.hidden = NO;
            self.bagClaimValueLabel_.hidden = NO;
        }
        else {
            self.bagClaimLabel_.hidden = YES;
            self.bagClaimValueLabel_.hidden = YES;
        }
    }
}


- (void)alternateData {
    // Show lands in only during the last hour of the flight
    BOOL showLandsIn = self.trackedFlight_.status != LANDED && [self.trackedFlight_.estimatedArrivalTime timeIntervalSinceNow] < 3600.0;
    BOOL showGate = self.trackedFlight_.destination && [self.trackedFlight_.destination.gate length] > 0;
    BOOL showTerminal = self.trackedFlight_.destination.terminal && [self.trackedFlight_.destination.terminal length] > 0;
    
    // Transition from lands at to lands in
    if (showLandsIn && (self.landsInLabel_.alpha < 1.0f || self.landsAtLabel_.alpha > 0.0f)) { // Only animate if needed
        [self fadeOut:self.landsAtLabel_ fadeIn:self.landsInLabel_];
        [self fadeOut:self.landsAtTimeLabel_ fadeIn:self.landsInTimeLabel_];
    }
    
    // Transition from lands in to lands at
    else if (self.landsAtLabel_.alpha < 1.0f || self.landsInLabel_.alpha > 0.0f) { // Only do it if needed
        [self fadeOut:self.landsInLabel_ fadeIn:self.landsAtLabel_];
        [self fadeOut:self.landsInTimeLabel_ fadeIn:self.landsAtTimeLabel_];
    }
    
    // Transition from terminal to gate
    if (showGate && (self.gateLabel_.alpha < 1.0f || self.terminalLabel_.alpha > 0.0f)) { // Only animate if needed
        [self fadeOut:self.terminalLabel_ fadeIn:self.gateLabel_];
        [self fadeOut:self.terminalValueLabel_ fadeIn:self.gateValueLabel_];
    }
    
    // Transition from gate to terminal
    else if (showTerminal && (self.terminalLabel_.alpha < 1.0f || self.gateLabel_.alpha > 0.0f)) { // Only do it if needed
        [self fadeOut:self.gateLabel_ fadeIn:self.terminalLabel_];
        [self fadeOut:self.gateValueLabel_ fadeIn:self.terminalValueLabel_];
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
#pragma mark - Start / Stop Tracking Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)track {
    // If location services are enabled, use them and let them trigger a /track
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager_ startUpdatingLocation];
    }
    else {
        // We aren't allowed to get location, or it's disabled, track now without
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.trackedFlight_ trackWithLocation:nil pushToken:appDelegate.pushToken];
    }
}

- (void)stopTrackingUserInitiated:(BOOL)userInitiated {
    [self.updateTimer_ invalidate];
    [self.alternatingLabelTimer_ invalidate];
    [self.locationManager_ stopUpdatingLocation];

    // Stop monitoring for movement
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate stopMonitoringMovement];
    
    [self.flightProgressView_ stopAnimating];
    [self.delegate didFinishTrackingFlight:self.trackedFlight_ userInitiated:userInitiated];
    self.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)willTrackFlight:(NSNotification *)notification {
    [self indicateUpdating];
}


- (void)didTrackFlight:(NSNotification *)notification {
    // Stop loading animation
    self.showingValidData_ = YES;
    [self indicateFinishedUpdating];
    
    // Update displayed information
    [self setStatus:self.trackedFlight_.status];
    [self setFlightNumber:self.trackedFlight_.flightNumber];
    self.originCodeLabel_.text = [self.trackedFlight_.origin bestAirportCode];
    self.originCityLabel_.text = [self.trackedFlight_.origin.city uppercaseString];
    self.destinationCodeLabel_.text = [self.trackedFlight_.destination bestAirportCode];
    self.destinationCityLabel_.text = [self.trackedFlight_.destination.city uppercaseString];
    self.flightProgressView_.timeOfDay = self.trackedFlight_.timeOfDay;
    self.flightProgressView_.aircraftType = self.trackedFlight_.aircraftType;
    self.flightProgressView_.progress = [self.trackedFlight_ currentProgress];
    self.landsAtLabel_.text = [self landsAtLabelText];
    self.landsAtTimeLabel_.parts = [self landsAtTimeParts];
    self.landsAtTimeLabel_.offsets = [self landsAtTimeOffsets]; // Need to recalc offsets
    self.landsInLabel_.text = [self landsInLabelText];
    self.landsInTimeLabel_.parts = [self landsInTimeParts];
    self.terminalLabel_.text = [self terminalLabelText];
    self.terminalValueLabel_.text = [self terminalValue];
    self.gateLabel_.text = [self gateLabelText];
    self.gateValueLabel_.text = [self gateValue];
    self.bagClaimValueLabel_.text = [self bagClaimValue];
    
    LeaveForAirportWarningType warningType = [self warningToDisplay];
    BOOL ignoreWarning = [ignoredWarnings_ containsObject:[NSNumber numberWithInteger:warningType]];
    
    if (self.trackedFlight_.leaveForAirportTime && self.trackedFlight_.drivingTime > 0.0 && (warningType == WarningTypeNone || ignoreWarning)) {
        self.leaveMeter_.showEmptyMeter = NO;
        self.leaveMeter_.timeRemaining = [self.trackedFlight_.leaveForAirportTime timeIntervalSinceNow];
    }
    else {
        self.leaveMeter_.showEmptyMeter = YES;
    }
    
    // Hide the directions button and driving time if appropriate
    [self showDrivingTimeOrBagClaim];
    
    // Show the warning button if appropriate
    self.warningButton_.hidden = (warningType == WarningTypeNone || ignoreWarning) ? YES : NO;
    
    // Figure out whether to offer to text their guest if they've arrived at the airport
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (!self.hasBeenToAirport_ && [self isAtAirport] && [JLMessageComposeViewController canSendText]) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            if (appDelegate.respondedToTextOnArrivalNotification) {
                [self composeTextOnAirportArrival];
                appDelegate.respondedToTextOnArrivalNotification = NO; // Reset this flag now that we've handled it
            }
            else {
                // The app is in the foreground, notify them right away
                NSString *alertMsg = (self.trackedFlight_.status == LANDED) ? NSLocalizedString(@"We can text the person you're picking up to let them know you've arrived.",
                                                                                                @"Text To Pickup Prompt - Flight Landed") :
                NSLocalizedString(@"We can text the person you're picking up to let them know you've arrived. They'll get your message once they land.", @"Text To Pickup Prompt - Flight Landed");
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Picking Someone Up?", @"Picking Someone Up?")
                                                                message:alertMsg
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Ignore", @"Ignore")
                                                      otherButtonTitles:NSLocalizedString(@"Send Text", @"Yes"), nil];
                alert.tag = TextUponArrivalAlertTag;
                [alert show];
                [FlurryAnalytics logEvent:FY_PROMPTED_TO_SEND_ARRIVAL_SMS];
                
                // Clear local notifications so they can't respond to prompt to pick somene up again
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            }
            self.hasBeenToAirport_ = YES;
        }
        else if (!self.hasBeenNotifiedToText_) {
            // The app is in the background, send them a local notification
            UILocalNotification *textNotification = [[UILocalNotification alloc] init];
            textNotification.alertAction = NSLocalizedString(@"Send Text", @"Send Text");
            textNotification.alertBody = NSLocalizedString(@"Picking someone up? Just Landed can text them that you've arrived.", @"Text Notification");
            textNotification.soundName = @"alert.wav";
            textNotification.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:JLLocalNotificationTypeTextOnArrival]
                                                                    forKey:LocalNotificationTypeKey];
            [[UIApplication sharedApplication] presentLocalNotificationNow:textNotification];
            self.hasBeenNotifiedToText_ = YES;
            [FlurryAnalytics logEvent:FY_NOTIFIED_TO_SEND_ARRIVAL_SMS];
        }
    }
    else {
        // Ask them to rate after a few seconds, if eligible
        [[JustLandedSession sharedSession] performSelector:@selector(showRatingRequestIfEligible)
                                                withObject:nil
                                                afterDelay:3.0];
    }
    
    if (!self.updateTimer_ || ![self.updateTimer_ isValid]) {
        [self.updateTimer_ invalidate];
        self.updateTimer_ = [NSTimer timerWithTimeInterval:1.0
                                                    target:self
                                                  selector:@selector(updateDisplayedData)
                                                  userInfo:nil
                                                   repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.updateTimer_ forMode:NSRunLoopCommonModes];
    }
    
    if (!self.alternatingLabelTimer_ || ![self.alternatingLabelTimer_ isValid]) {
        [self.alternatingLabelTimer_ invalidate];
        self.alternatingLabelTimer_ = [NSTimer timerWithTimeInterval:4.0
                                                              target:self
                                                            selector:@selector(alternateData)
                                                            userInfo:nil
                                                             repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.alternatingLabelTimer_ forMode:NSRunLoopCommonModes];
        [self.alternatingLabelTimer_ fire];
    }
    
    // End app delegate bg task if one was in progress
    [self finishWakeupTrackTask];
}


- (void)flightTrackFailed:(NSNotification *)notification {
    // Stop loading animation
    [self indicateFinishedUpdating];
    
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
            if (![self.trackedFlight_ isDataFresh] || !self.showingValidData_) { // Only show no connection if the data is old
                if (!self.noConnectionOverlay_) {
                    self.noConnectionOverlay_ = [[JLNoConnectionView alloc] initWithFrame:self.view.bounds];
                    self.noConnectionOverlay_.delegate = self;
                }
                self.noConnectionOverlay_.tryAgainButton.enabled = YES;
                
                [self.view addSubview:self.noConnectionOverlay_];
            }
            break;
        }
        default: {
            // Error or outage
            if (![self.trackedFlight_ isDataFresh] || !self.showingValidData_) { // Only show 500 if data is old or no data
                if (!self.serverErrorOverlay_) {
                    self.serverErrorOverlay_ = [[JLServerErrorView alloc] initWithFrame:self.view.bounds
                                                                         errorType:ERROR_500];
                    self.serverErrorOverlay_.delegate = self;
                }
                self.serverErrorOverlay_.tryAgainButton.enabled = YES;
                
                if (reason == TrackFailureOutage) {
                    self.serverErrorOverlay_.errorType = ERROR_503;
                }
                else {
                    self.serverErrorOverlay_.errorType = ERROR_500;
                }
                
                [self.view addSubview:self.serverErrorOverlay_];
            }
            break;
        }
    }
    
    // End app delegate bg task if one was in progress
    [self finishWakeupTrackTask];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getting Location & CLLocationDelegateMethods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isLocationAcceptable:(CLLocation *)loc {
    // Basic check
    if (loc == nil) return NO;
    
    // Decide whether it's acceptable age and accuracy range
    NSTimeInterval locAgeSecs = abs([loc.timestamp timeIntervalSinceNow]);
    return locAgeSecs <= LOCATION_MAXIMUM_ACCEPTABLE_AGE && loc.horizontalAccuracy <= LOCATION_MAXIMUM_ACCEPTABLE_ERROR;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // Only update if the new location is acceptable
    if ([self isLocationAcceptable:newLocation]) {
        // Update tracking information
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.trackedFlight_ trackWithLocation:newLocation pushToken:appDelegate.pushToken];
        
        // Update Flurry's location for this user
        [FlurryAnalytics setLatitude:newLocation.coordinate.latitude
                           longitude:newLocation.coordinate.longitude
                  horizontalAccuracy:newLocation.horizontalAccuracy
                    verticalAccuracy:newLocation.verticalAccuracy];
        
        // Stop updating now that we have an acceptable location
        [self.locationManager_ stopUpdatingLocation];
        
        // Start monitoring for refresh while active purposes
        [appDelegate startMonitoringMovementFromLocation:newLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch ([error code]) {
        case kCLErrorLocationUnknown: {
            // Indicate that we don't have location even though we were supposed to be able to use it
            [FlurryAnalytics logEvent:FY_UNABLE_TO_GET_LOCATION];
            break;
        }
        default:
            break;
    }
    
    // Track anyway, without location
    [self.locationManager_ stopUpdatingLocation];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.trackedFlight_ trackWithLocation:nil pushToken:appDelegate.pushToken];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tryConnectionAgain {
    [self track];
}

- (void)showMap {
    if ([MKMapItem class] && [MKMapItem respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        // iOS6 and later uses native Apple Maps with MKMapItems
        MKPlacemark *airportMark = [[MKPlacemark alloc] initWithCoordinate:self.trackedFlight_.destination.location.coordinate
                                                         addressDictionary:nil];
        
        MKMapItem *destItem = [[MKMapItem alloc] initWithPlacemark:airportMark];
        destItem.name = (self.trackedFlight_.destination.name) ? [NSString stringWithFormat:@"%@ (%@)",
                                                                  self.trackedFlight_.destination.name,
                                                                  [self.trackedFlight_.destination bestAirportCode]]:
                                                                  [self.trackedFlight_.destination bestAirportCode];
        
        [MKMapItem openMapsWithItems:[NSArray arrayWithObject:destItem]
                       launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey,
                                      [NSNumber numberWithInt:MKMapTypeStandard], MKLaunchOptionsMapTypeKey,
                                      [NSNumber numberWithBool:YES], MKLaunchOptionsShowsTrafficKey, nil]];
    }
    else {
        // Pre-iOS6 uses Google maps URLs with native Maps application
        // Trigger getting the location
        NSString *mapURL = nil;
        NSString *destName = [(self.trackedFlight_.destination.name) ? [NSString stringWithFormat:@"%@ [%@]",
                                                                        self.trackedFlight_.destination.name,
                                                                        [self.trackedFlight_.destination bestAirportCode]]:
                              [self.trackedFlight_.destination bestAirportCode] urlEncoded];
        NSString *origLoc = @"Current+Location";
        NSString *destLoc = [NSString stringWithFormat:@"%f,%f", 
                             self.trackedFlight_.destination.location.coordinate.latitude,
                             self.trackedFlight_.destination.location.coordinate.longitude];
        
        mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@@%@&layer=t&t=m",
                  origLoc, destName, destLoc];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURL]];
    }
    
    [FlurryAnalytics logEvent:FY_GOT_DIRECTIONS];
}


- (void)showWarning {
    LeaveForAirportWarningType warningType = [self warningToDisplay];
    NSString *alertTitle = nil;
    NSString *alertMessage = nil;
    NSString *cancelButtonTitle = NSLocalizedString(@"Ignore", @"Ignore");
    NSString *otherButtonTitle = NSLocalizedString(@"Fix", @"Fix");
    
    switch (warningType) {
        case WarningTypeDisabledLocationServices: {
            alertTitle = NSLocalizedString(@"Location Services Disabled", @"Location Services Disabled");
            alertMessage = NSLocalizedString(@"Without your location we can't estimate when you should leave for the airport to pick someone up.",
                                             @"Location Services Disabled Explanation");
            break;
        }
        case WarningTypeDeniedLocationServices: {
            alertTitle = NSLocalizedString(@"Location Services Denied", @"Location Services Denied");
            alertMessage = NSLocalizedString(@"You have chosen to not allow Just Landed to get your location. Without this information we can't estimate when you should leave for the airport to pick someone up.",
                                             @"Location Services Denied Explanation");
            break;
        }
        case WarningTypeRestrictedLocationServices: {
            alertTitle = NSLocalizedString(@"Location Services Restricted", @"Location Services Restricted");
            alertMessage = NSLocalizedString(@"Location Services are restricted on your device. Without this information we can't estimate when you should leave for the airport to pick someone up.",
                                             @"Location Services Restricted Explanation");
            break;
        }
        case WarningTypeDisallowedNotifications: {
            alertTitle = NSLocalizedString(@"Notifications Disabled", @"Notifications Disabled");
            alertMessage = NSLocalizedString(@"Because notifications are disabled, you will not receive alerts when it is time to go to the airport to pick someone up.",
                                             @"Notifications Disabled Explanation");
            break;
        }
        case WarningTypeTooFarFromDestination: {
            alertTitle = NSLocalizedString(@"Too Far From Destination", @"Too Far From Destination");
            alertMessage = NSLocalizedString(@"You are too far away from the destination to pick someone up from the airport.",
                                             @"Too Far From Destination Explanation");
            otherButtonTitle = nil;
            cancelButtonTitle = NSLocalizedString(@"OK", @"OK");
            break;
        }
        default:
            break;
    }
    
    if (warningType != WarningTypeNone) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:otherButtonTitle, nil];
        alert.tag = warningType;
        [alert show];
    }
}


- (void)backToLookup {
    [self stopTrackingUserInitiated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Handling Alerts
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TextUponArrivalAlertTag) {
        if ([alertView cancelButtonIndex] != buttonIndex) {
            // Show the message composer to text their guest
            [self composeTextOnAirportArrival];
        }
        else {
            [FlurryAnalytics logEvent:FY_IGNORED_ARRIVAL_SMS_PROMPT];
        }
    }
    else {
        NSString *title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
        NSURL *fixURL = nil;
        
        if ([alertView cancelButtonIndex] != buttonIndex) {
            switch (alertView.tag) {
                case WarningTypeDisabledLocationServices: {
                    fixURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, LOCATION_DISABLED_ANCHOR]];;
                    break;
                }
                case WarningTypeDeniedLocationServices: {
                    fixURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, LOCATION_DENIED_ANCHOR]];;
                    break;
                }
                case WarningTypeRestrictedLocationServices: {
                    fixURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, LOCATION_RESTRICTED_ANCHOR]];;
                    break;
                }
                case WarningTypeDisallowedNotifications: {
                    fixURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, PUSH_DISALLOWED_ANCHOR]];;
                    break;
                }
                case WarningTypeTooFarFromDestination: {
                    break;
                }
                default:
                    break;
            }
        }
        else if (alertView.tag > WarningTypeNone && alertView.tag <= WarningTypeTooFarFromDestination){
            // They want to ignore the warning
            if (![ignoredWarnings_ containsObject:[NSNumber numberWithInteger:alertView.tag]]) {
                [ignoredWarnings_ addObject:[NSNumber numberWithInteger:alertView.tag]];
            }
            
            // They want to ignore the warning
            self.warningButton_.hidden = YES;
        
            // Redisplay leave time if appropriate
            if (self.trackedFlight_.leaveForAirportTime && self.trackedFlight_.drivingTime > 0.0) {
                self.leaveMeter_.showEmptyMeter = NO;
                self.leaveMeter_.timeRemaining = [self.trackedFlight_.leaveForAirportTime timeIntervalSinceNow];
            }
            else {
                self.leaveMeter_.showEmptyMeter = YES;
            }
        }
        
        if (fixURL) {
            WebContentViewController *webContentVC = [[WebContentViewController alloc] initWithContentTitle:title URL:fixURL showDoneButton:YES];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webContentVC];
            navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:navController animated:YES completion:^{
                [FlurryAnalytics logEvent:FY_READ_FAQ];
            }];
        }
    }
}


- (void)composeTextOnAirportArrival {
    NSString *terminalName = nil;
    NSString *bagClaim = nil;
    NSString *smsMessage = nil;
    
    if (self.trackedFlight_.destination.terminal && [self.trackedFlight_.destination.terminal length] > 0) {
        terminalName = [self.trackedFlight_.destination.terminal isEqualToString:@"I"] ? NSLocalizedString(@"international terminal",
                                                                                                           @"International Terminal") :
        [NSString stringWithFormat:NSLocalizedString(@"terminal %@", @"terminal Y"), self.trackedFlight_.destination.terminal];
    }
    
    if (self.trackedFlight_.destination.bagClaim && [self.trackedFlight_.destination.bagClaim length] > 0) {
        bagClaim = self.trackedFlight_.destination.bagClaim;
    }
    
    
    if (terminalName && bagClaim) {
        smsMessage = [NSString stringWithFormat:NSLocalizedString(@"Hey, I'm at %@! I'm waiting for you in the %@ arrivals area. Bags are at claim %@. Sent using Just Landed http://bit.ly/QSXHN9",
                                                                  @"I've Arrived Message - Terminal & Bag Claim"),
                      [self.trackedFlight_.destination bestAirportCode],
                      terminalName,
                      bagClaim];
    }
    else if (terminalName) {
        smsMessage = [NSString stringWithFormat:NSLocalizedString(@"Hey, I'm at %@! I'm waiting for you in the %@ arrivals area. Sent using Just Landed http://bit.ly/ShKsQO",
                                                                  @"I've Arrived Message - Terminal Only"),
                      [self.trackedFlight_.destination bestAirportCode],
                      terminalName];
    }
    else if (bagClaim) {
        smsMessage = [NSString stringWithFormat:NSLocalizedString(@"Hey, I'm at %@! I'm waiting for you in the arrivals area. Bags are at claim %@. Sent using Just Landed http://bit.ly/QZt3fB",
                                                                  @"I've Arrived Message - Bag Claim Only"),
                      [self.trackedFlight_.destination bestAirportCode],
                      bagClaim];
    }
    else {
        smsMessage = [NSString stringWithFormat:NSLocalizedString(@"Hey, I'm at %@! I'm waiting for you in the arrivals area. Sent using Just Landed http://bit.ly/PexNjg",
                                                                  @"Basic I've Arrived Message"),
                      [self.trackedFlight_.destination bestAirportCode]];
    }
    
    JLMessageComposeViewController *smsComposer = [[JLMessageComposeViewController alloc] init];
    [smsComposer setMessageComposeDelegate:self];
    [smsComposer setBody:smsMessage];
    smsComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:smsComposer animated:YES completion:NULL];
    // Hack to fix MFMMessageCompose changing status bar type
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [FlurryAnalytics logEvent:FY_STARTED_SENDING_ARRIVED_SMS];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MFMessageComposeViewControllerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent) {
        [FlurryAnalytics logEvent:FY_SENT_ARRIVED_SMS];
    }
    else if (result == MessageComposeResultCancelled) {
        [FlurryAnalytics logEvent:FY_ABANDONED_SENDING_ARRIVED_SMS];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Background Task Cleanup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)finishWakeupTrackTask {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.wakeupTrackTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:appDelegate.wakeupTrackTask];
        appDelegate.wakeupTrackTask = UIBackgroundTaskInvalid;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [updateTimer_ invalidate];
    [alternatingLabelTimer_ invalidate];
    [locationManager_ stopUpdatingLocation];
    locationManager_.delegate = nil;
    noConnectionOverlay_.delegate = nil;
    serverErrorOverlay_.delegate = nil;
}

@end
