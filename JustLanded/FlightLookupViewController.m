//
//  FlightLookupViewController.m
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "FlightLookupViewController.h"
#import "FlightResultTableViewCell.h"
#import "AboutViewController.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FlightLookupViewController ()

@property (strong, nonatomic) JLButton *_lookupButton;
@property (strong, nonatomic) JLButton *_airportCodesButton;
@property (strong, nonatomic) JLButton *_airportCodesLabelButton;
@property (strong, nonatomic) JLFlightInputField *_flightNumberField;
@property (strong, nonatomic) UITableView *_flightResultsTable;
@property (strong, nonatomic) UIImageView *_airplane;
@property (strong, nonatomic) UIImageView *_flightResultsTableFrame;
@property (strong, nonatomic) JLSpinner *_lookupSpinner;
@property (strong, nonatomic) NSTimer *_airplaneTimer;
@property (strong, nonatomic) NSArray *_flightResults;
@property (strong, nonatomic) JLCloudLayer *_cloudLayer;

+ (NSString *)sanitizedFlightNum:(NSString *)flightNum;
+ (BOOL)isFlightNumValid:(NSString *)flightNum;
+ (BOOL)isFlightNumInteger:(NSString *)flightNum;
+ (BOOL)flightNumContainsValidAirlineCode:(NSString *)flightNum;
+ (NSArray *)splitFlightNumber:(NSString *)flightNumber;
- (void)flightLookupFailed:(NSNotification *)notification;
- (void)willLookupFlight:(NSNotification *)notification;
- (void)didLookupFlight:(NSNotification *)notification;
- (void)doLookup;
- (void)lookupCodes;
- (void)indicateLookingUp;
- (void)indicateStoppedLookingUp;
- (void)showAboutScreen;
- (void)animatePlane;
- (void)allowLookup;
- (void)disallowLookup;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FlightLookupViewController

@synthesize _lookupButton;
@synthesize _airportCodesButton;
@synthesize _airportCodesLabelButton;
@synthesize _flightNumberField;
@synthesize _flightResultsTable;
@synthesize _airplane;
@synthesize _flightResultsTableFrame;
@synthesize _lookupSpinner;
@synthesize _airplaneTimer;
@synthesize _flightResults;
@synthesize _cloudLayer;

static NSRegularExpression *_flightNumberRegex;
static NSRegularExpression *_airlineCodeRegex;
NSUInteger const FLIGHT_NUMBER_EXPLANATION_ALERT = 999;


+ (void)initialize {
    if (self == [FlightLookupViewController class]) {
        NSError *error = NULL;
        _flightNumberRegex = [NSRegularExpression regularExpressionWithPattern:@"\\A[A-Z0-9]{2}[A-Z]{0,1}[0-9]{1,4}[A-Z]{0,1}\\Z"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:&error];
        _airlineCodeRegex = [NSRegularExpression regularExpressionWithPattern:@"\\A[A-Z][0-9][A-Z]{0,1}|\\A[0-9][A-Z]{1,2}|\\A[A-Z]{2,3}|\\A[A-Z0-9]{2}"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    }
}


+ (NSString *)sanitizedFlightNum:(NSString *)flightNum {
    if ([flightNum length] > 0) {
        // Uppercase and strip spaces
        NSString *sanitizedNum = [[flightNum uppercaseString] stringByReplacingOccurrencesOfString:@" "
                                                                                        withString:@""];
        
        // Strip leading zeros
        NSMutableArray *chars = [[NSMutableArray alloc] init];
        BOOL strip = YES;
        for (int i=0; i < [sanitizedNum length]; i++) {
            NSString *ichar  = [NSString stringWithFormat:@"%c", [sanitizedNum characterAtIndex:i]];
            if (strip && [ichar rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
                if ([ichar isEqualToString:@"0"]) {
                    continue;
                }
                else {
                    strip = NO;
                }
            }
            [chars addObject:ichar];
        }
        
        return [chars componentsJoinedByString:@""];
    }
    else {
        return @"";
    }
}


+ (BOOL)isFlightNumValid:(NSString *)flightNum {
    if (flightNum == nil) {
        return NO;
    }
    
    NSString *sanitizedNum = [self sanitizedFlightNum:flightNum];
    NSUInteger numMatches = [_flightNumberRegex numberOfMatchesInString:sanitizedNum
                                                                options:0
                                                                  range:NSMakeRange(0, [sanitizedNum length])];
    return (numMatches == 1) ? YES : NO;
}


+ (BOOL)isFlightNumInteger:(NSString *)flightNum {
    NSScanner *scanner = [NSScanner scannerWithString:[self sanitizedFlightNum:flightNum]];
    NSInteger val;
    return [scanner scanInteger:&val] && [scanner isAtEnd];
}


+ (NSArray *)splitFlightNumber:(NSString *)flightNumber {
    if ([self isFlightNumValid:flightNumber]) {
        NSString *sanitizedNum = [self sanitizedFlightNum:flightNumber];
        NSTextCheckingResult *result = [_airlineCodeRegex firstMatchInString:sanitizedNum
                                                                     options:NSMatchingAnchored
                                                                       range:NSMakeRange(0, [sanitizedNum length])];
        if (result.range.location != NSNotFound) {
            return [NSArray arrayWithObjects:[sanitizedNum substringWithRange:result.range],
                    [sanitizedNum substringFromIndex:result.range.length], nil];
        }
        else {
            // Unable to split - no valid airline code
            return [NSArray arrayWithObject:sanitizedNum];
        }
    }
    else {
        return [NSArray array];
    }
}


+ (BOOL)flightNumContainsValidAirlineCode:(NSString *)flightNum {
    NSArray *parts = [[self class] splitFlightNumber:flightNum];
    if ([parts count] == 2 && [AirlineLookupViewController airlineCodeExists:[parts objectAtIndex:0]]) {
        return YES;
    }
    else {
        return NO;
    }
}


- (id)init {
    self = [super init];
    
    if (self) {
        // Listen for flight lookup notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flightLookupFailed:) 
                                                     name:FlightLookupFailedNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willLookupFlight:) 
                                                     name:WillLookupFlightNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLookupFlight:) 
                                                     name:DidLookupFlightNotification 
                                                   object:nil];
        
    }
    
    return self;
}


- (void)beginTrackingFlight:(Flight *)aFlight animated:(BOOL)animateFlip {
    [[JustLandedSession sharedSession] addTrackedFlight:aFlight];
    FlightTrackViewController *controller = [[FlightTrackViewController alloc] initWithFlight:aFlight];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [_cloudLayer stopAnimating]; // Stop animating the clouds
    [self stopAnimatingPlane];
    [self presentModalViewController:controller animated:animateFlip];
    
    // If animated, was user-initiated, record the track
    if (animateFlip) {
        [[JustLandedSession sharedSession] incrementTrackCount];
        
        [FlurryAnalytics logEvent:FY_BEGAN_TRACKING_FLIGHT 
                   withParameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", [aFlight minutesBeforeLanding]]
                                                              forKey:@"Minutes Before Landing"]];
        
    }
}


- (void)indicateLookingUp {
    self._flightNumberField.enabled = NO;
    self._lookupButton.hidden = YES;
    self._airportCodesButton.hidden = YES;
    self._airportCodesLabelButton.hidden = YES;
    [_lookupSpinner startAnimating];
}


- (void)indicateStoppedLookingUp {
    [_lookupSpinner stopAnimating];
    self._flightNumberField.enabled = YES;
    
    self._lookupButton.hidden = NO;
    self._airportCodesButton.hidden = NO;
    self._airportCodesLabelButton.hidden = NO;
    
    if ([[self class] isFlightNumValid:_flightNumberField.text]) {
        [self allowLookup];
    }
    else {
        [self disallowLookup];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)doLookup {
    NSString *flightNumber = [[[_flightNumberField text] uppercaseString] stringByReplacingOccurrencesOfString:@" " 
                                                                                                    withString:@""];
    if ([[self class] isFlightNumValid:flightNumber]) {
        [_flightNumberField resignFirstResponder];
        [Flight lookupFlights:flightNumber];
    }
}


- (void)lookupCodes {
    AirlineLookupViewController *airlineLookupVC = [[AirlineLookupViewController alloc] init];
    airlineLookupVC.delegate = self;
    UINavigationController *airlineLookupNavVC = [[UINavigationController alloc] initWithRootViewController:airlineLookupVC];
    airlineLookupNavVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:airlineLookupNavVC animated:YES];
    [FlurryAnalytics logEvent:FY_BEGAN_AIRLINE_LOOKUP];
}


- (void)showAboutScreen {
    AboutViewController *aboutController = [[AboutViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutController];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navController animated:YES];
    [FlurryAnalytics logEvent:FY_VISITED_ABOUT_SCREEN];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Responding to Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)flightLookupFailed:(NSNotification *)notification {
    [self indicateStoppedLookingUp];
    
    FlightLookupFailedReason reason = [[[notification userInfo] valueForKey:FlightLookupFailedReasonKey] integerValue];
    
    switch (reason) {
        case LookupFailureInvalidFlightNumber: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Flight Number", @"Invalid Flight Number") 
                                                            message:NSLocalizedString(@"Please check that you entered your flight number correctly.",
                                                                                      @"Please check flight #")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Try Again", @"Try Again")
                                                  otherButtonTitles:nil];
            alert.tag = LookupFailureInvalidFlightNumber;
            [alert show];
            break;   
        }
        case LookupFailureNoCurrentFlight: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't Track Flight Yet", @"No Current Flight")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Flight %@ is not arriving in the next 48 hours. Please try again closer to the arrival date.",
                                                                                      @"No Current Flight Explanantion"), _flightNumberField.text]
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }
        case LookupFailureFlightNotFound: {
            UIAlertView *alert;
            
            if ([[self class] isFlightNumInteger:_flightNumberField.text]) {
                // They've entered all numbers - not understanding desired input
                alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Airline Code", @"Missing Airline Code")
                                                    message:NSLocalizedString(@"Flight numbers are made up of an airline code and a number e.g.UA72. Don't know the airline code? We can look it up for you!", @"Airline Code Explanation")
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Lookup Airline Code", @"Lookup Airline Code"), nil];
                alert.tag = FLIGHT_NUMBER_EXPLANATION_ALERT;
            }
            else if (![[self class] flightNumContainsValidAirlineCode:_flightNumberField.text]) {
                // They've entered an invalid airline code
                NSArray *flightNumParts = [[self class] splitFlightNumber:_flightNumberField.text];
                NSString *airlineCode = ([flightNumParts count] == 2) ? [flightNumParts objectAtIndex:0] : _flightNumberField.text;
                
                alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unknown Airline Code", @"Unknown Airline Code")
                                                   message:[NSString stringWithFormat:NSLocalizedString(@"We don't recognize airline code %@. Don't know the airline code? We can look it up for you!", @"Unknown Airline Code Explanation"),
                                                            airlineCode]
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Lookup Airline Code", @"Lookup Airline Code"), nil];
                alert.tag = FLIGHT_NUMBER_EXPLANATION_ALERT;
            }
            else {
                // Code is valid, not all numbers, we just don't have it
                alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Flight %@ Not Found", @"Flight XYZ Not Found"),
                                                            _flightNumberField.text]
                                                   message:[NSString stringWithFormat:NSLocalizedString(@"Unfortunately we don't have information for flight %@. We've recorded this missing flight and will try to add it in the future.",
                                                                             @"Flight not found."), _flightNumberField.text]
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                         otherButtonTitles:nil];
                alert.tag = LookupFailureFlightNotFound;
            }
            
            [alert show];
            break;
        }
        case LookupFailureNoConnection: {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet Connection", 
                                                                                       @"No Internet Connection")
                                                          message:NSLocalizedString(@"Please check your wireless signal and try again.",
                                                                                    @"Please check your connection.")
                                                         delegate:self 
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                otherButtonTitles:nil];
            alert.tag = LookupFailureNoConnection;
            [alert show];
            break;
        }
        case LookupFailureOutage: {
            // Outage
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Service Outage", 
                                                                                      @"Service Outage")
                                                            message:NSLocalizedString(@"Just Landed is currently unavailable. Our engineers are working to restore service. Please try again later.",
                                                                                      @"Service outage msg.")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            alert.tag = LookupFailureOutage;
            [alert show];
            break; 
        }
        default: {
            // Some error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server Error", 
                                                                                      @"Server Error")
                                                            message:NSLocalizedString(@"An error has occurred. Our engineers have been notified. Please try again later.",
                                                                                      @"Server error msg.")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            alert.tag = LookupFailureError;
            [alert show];
            break; 
        }
    }
}


- (void)willLookupFlight:(NSNotification *)notification {
    [self indicateLookingUp];
}


- (void)didLookupFlight:(NSNotification *)notification {
    NSArray *flights = [[notification userInfo] valueForKey:@"flights"];
    [self indicateStoppedLookingUp];
    
    if (flights) {
        self._flightResults = flights;
    
        if ([flights count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Flight %@ Not Found", @"Flight XYZ Not Found"),
                                                                     _flightNumberField.text]
                                                            message:NSLocalizedString(@"Just Landed can only track flights that are arriving at US, UK, French or Canadian airports within the next 48 hours.",
                                                                                      @"Just Landed Flight Not Found")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else if ([flights count] == 1) {
            [self beginTrackingFlight:[flights objectAtIndex:0] animated:YES];
        }
        else {
            [self._flightResultsTable reloadData];
            [self._flightResultsTable setContentOffset:CGPointZero];
            self._lookupButton.hidden = YES;
            self._airportCodesButton.hidden = YES;
            self._airportCodesLabelButton.hidden = YES;
            self._flightResultsTable.hidden = NO;
            self._flightResultsTableFrame.hidden = NO;
        }
    
        [FlurryAnalytics logEvent:FY_LOOKED_UP_FLIGHT 
                   withParameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", [flights count]] 
                                                                                         forKey:@"Number Of Results"]];
    }
}


- (UITextField *)flightNumberField {
    return _flightNumberField;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    // Configure the main view
    UIImageView *mainView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    mainView.backgroundColor = [UIColor blackColor];
    mainView.image = [UIImage imageNamed:@"lookup_bg"];
    mainView.userInteractionEnabled = YES;
    self.view = mainView;
    
    // Add the cloud layer
    self._cloudLayer = [[JLCloudLayer alloc] initWithFrame:CLOUD_LAYER_FRAME];
    self._cloudLayer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_cloudLayer];
    
    // Add the cloud foreground
    UIImageView *cloudFg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"lookup_cloud_fg"] 
                                                               resizableImageWithCapInsets:UIEdgeInsetsMake(9.0f, 9.0f, 9.0f, 9.0f)]];
    cloudFg.frame = CLOUD_FOOTER_FRAME;
    cloudFg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:cloudFg];
    
    // Add the logo
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    logo.frame = LOGO_FRAME;
    [self.view addSubview:logo];
    
    // Add the about button
    JLButton *aboutButton = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles aboutButtonStyle] frame:ABOUT_BUTTON_FRAME];
    [aboutButton addTarget:self action:@selector(showAboutScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutButton];
    
    // Add the input field
    JLFlightInputField *flightNumField = [[JLFlightInputField alloc] initWithFrame:LOOKUP_TEXTFIELD_FRAME];
    flightNumField.delegate = self;
    flightNumField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self._flightNumberField = flightNumField;
    
    UIImageView *lookupInputContainer = [[UIImageView alloc] initWithFrame:LOOKUP_INPUT_FRAME];
    lookupInputContainer.image = [[UIImage imageNamed:@"lookup_input_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)];
    lookupInputContainer.userInteractionEnabled = YES;
    [lookupInputContainer addSubview:flightNumField];
    lookupInputContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:lookupInputContainer];
    
    // Add the airport codes button and the airport codes label
    self._airportCodesLabelButton = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles airportCodesLabelButtonStyle] frame:AIRPORT_CODES_LABEL_FRAME];
    [_airportCodesLabelButton setTitle:NSLocalizedString(@"Don't know the airline code?", @"Airline Lookup Prompt")
                              forState:UIControlStateNormal];
    self._airportCodesLabelButton.alpha = [[self class] isFlightNumValid:_flightNumberField.text] ? 0.0f : 1.0f;
    [_airportCodesLabelButton addTarget:self action:@selector(lookupCodes) forControlEvents:UIControlEventTouchUpInside];
    _airportCodesLabelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_airportCodesLabelButton];
    
    self._airportCodesButton = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles airportCodesButtonStyle] frame:AIRPORT_CODES_BUTTON_FRAME];
    self._airportCodesButton.alpha = [[self class] isFlightNumValid:_flightNumberField.text] ? 0.0f : 1.0f;
    [_airportCodesButton addTarget:self action:@selector(lookupCodes) forControlEvents:UIControlEventTouchUpInside];
    _airportCodesButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_airportCodesButton];
    
    // Add the lookup button
    JLButton *lookupButton = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles lookupButtonStyle] frame:LOOKUP_BUTTON_FRAME];
    [lookupButton setTitle:NSLocalizedString(@"Find Flight", @"Find Flight") forState:UIControlStateNormal];
    lookupButton.alpha = [[self class] isFlightNumValid:_flightNumberField.text] ? 1.0f : 0.0f;
    [lookupButton addTarget:self action:@selector(doLookup) forControlEvents:UIControlEventTouchUpInside];
    lookupButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self._lookupButton = lookupButton;
    [self.view addSubview:lookupButton];
    
    // Add the results table
    UITableView *resultsTable = [[UITableView alloc] initWithFrame:RESULTS_TABLE_FRAME style:UITableViewStylePlain];
    resultsTable.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:236.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    resultsTable.layer.cornerRadius = 6.0f;
    resultsTable.layer.masksToBounds = YES;
    resultsTable.dataSource = self;
    resultsTable.delegate = self;
    resultsTable.hidden = YES;
    resultsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    resultsTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    resultsTable.scrollIndicatorInsets = UIEdgeInsetsMake(2.0f, 0.0f, 2.0f, 2.0f);
    resultsTable.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self._flightResultsTable = resultsTable;
    [self.view addSubview:resultsTable];
    
    // Add the airplane
    _airplane = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plane_contrail"]];
    _airplane.frame = CGRectMake(-_airplane.frame.size.width, // Place offscreen
                                 85.0f,
                                 _airplane.frame.size.width,
                                 _airplane.frame.size.height);
    _airplane.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_airplane];
    
    // Add the table frame
    UIImage *tableFrame = [[UIImage imageNamed:@"table_frame"] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0f, 11.0f, 11.0f, 11.0f)];
    self._flightResultsTableFrame = [[UIImageView alloc] initWithImage:tableFrame];
    self._flightResultsTableFrame.frame = RESULTS_TABLE_CONTAINER_FRAME;
    self._flightResultsTableFrame.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_flightResultsTableFrame];
    
    // Add the lookup spinner
    _lookupSpinner = [[JLSpinner alloc] initWithFrame:CGRectMake(103.0f, 278.0f, 114.0f, 115.0f)];
    _lookupSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_lookupSpinner];
}


- (void)viewDidLoad {
    [_cloudLayer startAnimating];
    [self startAnimatingPlane];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self._lookupButton = nil;
    self._airportCodesButton = nil;
    self._airportCodesLabelButton = nil;
    self._flightNumberField = nil;
    self._flightResultsTable = nil;
    self._flightResultsTableFrame = nil;
    self._lookupSpinner = nil;
    self._airplane = nil;
    self._cloudLayer = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Supports portrait only
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)startAnimatingPlane {
    if (!_airplaneTimer || ![_airplaneTimer isValid]) {
        // Reset
        [_airplane setFrame:CGRectMake(-_airplane.frame.size.width,
                                       _airplane.frame.origin.y,
                                       _airplane.frame.size.width,
                                       _airplane.frame.size.height)];
        
        _airplaneTimer = [NSTimer timerWithTimeInterval:(arc4random() % 30) 
                                                 target:self
                                               selector:@selector(animatePlane) 
                                               userInfo:nil 
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_airplaneTimer forMode:NSRunLoopCommonModes];
    }
}


- (void)stopAnimatingPlane {
    [_airplaneTimer invalidate];
}


- (void)animatePlane {
    // Start the animation over only if the plane is in the reset position
    if (_airplane.frame.origin.x <= -_airplane.frame.size.width) {
        //Reset
        [UIView animateWithDuration:120.0 
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             [_airplane setFrame:CGRectMake(_airplane.frame.size.width,
                                                            _airplane.frame.origin.y,
                                                            _airplane.frame.size.width,
                                                            _airplane.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [_airplane setFrame:CGRectMake(-_airplane.frame.size.width,
                                                                _airplane.frame.origin.y,
                                                                _airplane.frame.size.width,
                                                                _airplane.frame.size.height)];
                             }
                         }];
    }
}


- (void)allowLookup {
    self._lookupButton.enabled = YES;
    self._airportCodesButton.enabled = NO;
    self._airportCodesLabelButton.enabled = NO;
    
    [UIView animateWithDuration:0.125
                          delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         _airportCodesButton.alpha = 0.0f;
                         _airportCodesLabelButton.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.125 
                                               delay:0.0 
                                             options:UIViewAnimationOptionBeginFromCurrentState 
                                          animations:^{
                                              _lookupButton.alpha = 1.0f;
                                          }
                                          completion:NULL];
                     }];
}


- (void)disallowLookup {
    self._lookupButton.enabled = NO;
    self._airportCodesButton.enabled = YES;
    self._airportCodesLabelButton.enabled = YES;
    
    [UIView animateWithDuration:0.125 
                          delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         _lookupButton.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.125 
                                               delay:0.0 
                                             options:UIViewAnimationOptionBeginFromCurrentState 
                                          animations:^{
                                              _airportCodesButton.alpha = 1.0f;
                                              _airportCodesLabelButton.alpha = 1.0f;
                                          }
                                          completion:NULL];
                     }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self._flightResultsTable.hidden = YES;
    self._flightResultsTableFrame.hidden = YES;
    self._lookupButton.hidden = NO;
    self._airportCodesButton.hidden = NO;
    self._airportCodesLabelButton.hidden = NO;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self disallowLookup];
    self._flightNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
    [self._flightNumberField.textInputView reloadInputViews];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL validFlightNum = [[self class] isFlightNumValid:textField.text];
    
    // Stop them from searching for a non-existent integer flight airline code + number
    if (validFlightNum && (![[self class] isFlightNumInteger:textField.text] || [[self class] flightNumContainsValidAirlineCode:textField.text])) {
        [self doLookup];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Flight Number", @"Invalid Flight Number")
                                                        message:NSLocalizedString(@"Flight numbers are made up of an airline code and a number. For example, to find United Airlines flight 72, you would enter UA72.", @"Airline Code Explanation")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Lookup Airline Code", @"Lookup Airline Code"), nil];
        alert.tag = FLIGHT_NUMBER_EXPLANATION_ALERT;
        [alert show];
        
    }
    return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Force uppercase
    NSString *oldText = [[textField text] uppercaseString];
    NSString *newText = [[[textField text] stringByReplacingCharactersInRange:range withString:string] uppercaseString];
    BOOL colorTextAsError = NO;
    
    if ([newText length] < 9) {
        [textField setText:newText];
    }
    
    // Enable/disable lookup button based on whether flight num is valid
    if ([[self class] isFlightNumValid:newText]) {
        BOOL containsValidAirlineCode = [[self class] flightNumContainsValidAirlineCode:newText];
        
        if ([[self class] isFlightNumInteger:textField.text] && !containsValidAirlineCode) {
            [self disallowLookup];
        }
        else {
            [self allowLookup];
        }
            
        // If the airline code is there but doesn't exist, color the text red
        if (!containsValidAirlineCode) {
            colorTextAsError = YES;
        }
    }
    else {
        [self disallowLookup];
        
        // If they've typed enough characters for a valid flight num, and it's still not valid, color red
        if ([[[self class] sanitizedFlightNum:newText] length] >= 4) {
            colorTextAsError = YES;
        }
        
        if ([newText length] < [oldText length]) {
            self._flightNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
            [self._flightNumberField.textInputView reloadInputViews];
        }
    }
    
    // Color the text red or normal
    self._flightNumberField.errorState = colorTextAsError ? FlightInputError : FlightInputNoError;

    return NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == LookupFailureFlightNotFound || alertView.tag == LookupFailureInvalidFlightNumber) {
        // Clear the field only on bad flight # or flight number not found
        self._flightNumberField.text = @"";
        self._flightNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
        [self._flightNumberField.textInputView reloadInputViews];
        [self._flightNumberField becomeFirstResponder];
        [self disallowLookup];
    }
    else if (alertView.tag == FLIGHT_NUMBER_EXPLANATION_ALERT) {
        self._flightNumberField.text = @"";
        [self._flightNumberField becomeFirstResponder];
        [self disallowLookup];
        
        if ([alertView cancelButtonIndex] != buttonIndex) {
            [self lookupCodes];
        }
    }
    else {
        self._flightNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
        [self._flightNumberField.textInputView reloadInputViews];
        [self._flightNumberField becomeFirstResponder];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource & UITableViewDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Flight *chosenFlight = [self._flightResults objectAtIndex:[indexPath row]];
    [self beginTrackingFlight:chosenFlight animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FlightResultTableViewCell *cell = (FlightResultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FlightResultTableViewCell"];
    
    if (!cell) {
        cell = [[FlightResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                reuseIdentifier:@"FlightResultTableViewCell"];
        cell.opaque = NO;
        cell.backgroundView.opaque = NO;
        cell.selectedBackgroundView.opaque = NO;
    }
    
    Flight *aFlight = [self._flightResults objectAtIndex:[indexPath row]];
    
    // Figure out the cell type
    if (indexPath.row == 0) {
        cell.cellType = TOP;
    }
    else if (indexPath.row + 1 == [tableView numberOfRowsInSection:indexPath.section]) {
        cell.cellType = BOTTOM;
    }
    else {
        cell.cellType = MIDDLE;
    }
    
    // Display the airports
    cell.fromAirport = aFlight.origin.city ? aFlight.origin.city : (aFlight.origin.iataCode ?
                                                                            aFlight.origin.iataCode :
                                                                            aFlight.origin.icaoCode);
    
    cell.toAirport = aFlight.destination.city ? aFlight.destination.city : (aFlight.destination.iataCode ?
                                                                            aFlight.destination.iataCode :
                                                                            aFlight.destination.icaoCode);
    
    // Display time information about the flight
    switch (aFlight.status) {
        case LANDED:
            cell.landingTime = [[NSDate naturalDateStringFromDate:[aFlight actualArrivalTime] withTimezone:aFlight.destination.timezone] uppercaseString];
            break;
        default:
            cell.landingTime = [[NSDate naturalDateStringFromDate:[aFlight scheduledArrivalTime] withTimezone:aFlight.destination.timezone] uppercaseString];
            break;
    }
    
    // Display the status of the flight
    cell.statusColor = [JLStyles colorForStatus:aFlight.status];
    cell.statusShadowColor = [JLStyles labelShadowColorForStatus:aFlight.status];
    cell.status = [JLStyles statusTextForStatus:aFlight.status];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self._flightResults count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self._flightResults count] - 1) {
        return FlightResultTableViewCellHeight + 2.0f;
    }
    else {
        return FlightResultTableViewCellHeight;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FlightTrackViewControllerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didFinishTrackingFlight:(Flight *)aFlight userInitiated:(BOOL)userFlag {
    self._flightResultsTable.hidden = YES;
    self._flightResultsTableFrame.hidden = YES;
    self._lookupButton.hidden = NO;
    self._airportCodesButton.hidden = NO;
    self._airportCodesLabelButton.hidden = NO;
    [_cloudLayer startAnimating]; // Begin animating the cloud layer
    [self startAnimatingPlane];
    
    // If the user stopped tracking, pre-fill the field with the flight they were tracking
    if (userFlag) {
        self._flightNumberField.text = aFlight.flightNumber;
        [FlurryAnalytics logEvent:FY_STOPPED_TRACKING_FLIGHT 
                   withParameters:[NSDictionary dictionaryWithObject:(aFlight.status == LANDED) ? @"YES" : @"NO"
                                                              forKey:@"Flight Landed"]];
    }
    else {
        // Probably an old flight, clear the field
        self._flightNumberField.text = @"";
    }
    
    
    if ([[self class] isFlightNumValid:_flightNumberField.text]) {
        [self allowLookup];
    }
    else {
        [self disallowLookup];
    }
        
    [[JustLandedSession sharedSession] removeTrackedFlight:aFlight];
    [aFlight stopTracking];
    
    self._flightNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
    [self._flightNumberField.textInputView reloadInputViews];
    [self._flightNumberField becomeFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - AirlineLookupDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didChooseAirlineCode:(NSString *)airlineCode {
    [self disallowLookup];
    self._flightNumberField.text = airlineCode;
    self._flightNumberField.errorState = FlightInputNoError;
    [self._flightNumberField becomeFirstResponder];
    self._flightNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [self._flightNumberField.textInputView reloadInputViews];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)cancelledAirlineLookup {
    [self dismissModalViewControllerAnimated:YES];
    [FlurryAnalytics logEvent:FY_CANCELED_AIRLINE_LOOKUP];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _flightNumberField.delegate = nil;
    _flightResultsTable.delegate = nil;
    [_cloudLayer stopAnimating];
    [self stopAnimatingPlane];
}

@end
