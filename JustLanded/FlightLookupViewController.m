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
#import "WebContentViewController.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
    LookupErrorInvalidFlightNumber = 0,
    LookupErrorFlightNotFound,
    LookupErrorNonexistentAirline,
    LookupErrorNoCurrentFlight,
    LookupErrorFlightNumberMissingAirlineCode,
    LookupErrorOutage,
    LookupErrorNoConnection,
    LookupErrorServerError,
} LookupErrorType;


@interface FlightLookupViewController ()

@property (strong, nonatomic) JLButton *_lookupButton;
@property (strong, nonatomic) JLButton *_airportCodesButton;
@property (strong, nonatomic) JLButton *_airportCodesLabelButton;
@property (strong, nonatomic) JLFlightInputField *_flightNumberField;
@property (strong, nonatomic) UITableView *_flightResultsTable;
@property (strong, nonatomic) JLAirplaneView *_airplane;
@property (strong, nonatomic) UIImageView *_flightResultsTableFrame;
@property (strong, nonatomic) JLSpinner *_lookupSpinner;
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
- (void)alertWithError:(LookupErrorType)errorType;
- (void)doLookup;
- (void)lookupCodes;
- (void)indicateLookingUp;
- (void)indicateStoppedLookingUp;
- (void)showAboutScreen;
- (void)allowLookup;
- (void)disallowLookup;
- (void)clearFlightNumberField;
- (void)resetFlightInputKeyboard;
- (void)dismissVC;

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
@synthesize _flightResults;
@synthesize _cloudLayer;

static NSRegularExpression *_flightNumberRegex;
static NSRegularExpression *_airlineCodeRegex;


+ (void)initialize {
    if (self == [FlightLookupViewController class]) {
        NSError *error = NULL;
        _flightNumberRegex = [NSRegularExpression regularExpressionWithPattern:@"\\A[A-Z0-9]{2}[A-Z]{0,1}[0-9]{1,4}[A-Z]{0,1}\\Z"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:&error];
        _airlineCodeRegex = [NSRegularExpression regularExpressionWithPattern:@"\\A[A-Z][0-9][A-Z]{0,1}|\\A[0-9][A-Z]{1,2}|\\A[A-Z]{2,3}"
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
        for (NSUInteger i=0; i < [sanitizedNum length]; i++) {
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
                                                                options:NSMatchingAnchored
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
    [_airplane stopAnimating];
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
    [_flightNumberField resignFirstResponder];
    [Flight lookupFlights:[[self class] sanitizedFlightNum:_flightNumberField.text]];
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
    aboutController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // HACK: Causes loadview to fire, which causes offsetting clouds before animation to work, and adds airplane to aboutController view
    aboutController.airplane = _airplane;
    aboutController.cloudLayer.currentCloudOffsets = _cloudLayer.currentCloudOffsets;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController
                       animated:NO // Instant transition
                     completion:^{
                         [aboutController revealContent];
                     }];
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
            [self alertWithError:LookupErrorInvalidFlightNumber];
            break;   
        }
        case LookupFailureNoCurrentFlight: {
            [self alertWithError:LookupErrorNoCurrentFlight];
            break;
        }
        case LookupFailureFlightNotFound: {
            if ([[self class] isFlightNumInteger:_flightNumberField.text]) {
                // They've entered all numbers - not understanding desired input
                [self alertWithError:LookupErrorFlightNumberMissingAirlineCode];
            }
            else if (![[self class] flightNumContainsValidAirlineCode:_flightNumberField.text]) {
                // They've entered an invalid airline code
                [self alertWithError:LookupErrorNonexistentAirline];
            }
            else {
                // Code is valid, not all numbers, we just don't have it
                [self alertWithError:LookupErrorFlightNotFound];
            }
            break;
        }
        case LookupFailureNoConnection: {
            [self alertWithError:LookupErrorNoConnection];
            break;
        }
        case LookupFailureOutage: {
            // Outage
            [self alertWithError:LookupErrorOutage];
            break; 
        }
        default: {
            // Some error
            [self alertWithError:LookupErrorServerError];
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
            [self alertWithError:LookupErrorFlightNotFound];
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


- (void)alertWithError:(LookupErrorType)errorType {
    NSString *alertTitle = nil;
    NSString *alertMessage = nil;
    NSString *cancelButtonTitle = nil;
    NSString *otherButtonTitle = nil;
    
    switch (errorType) {
        case LookupErrorInvalidFlightNumber: {
            alertTitle = NSLocalizedString(@"Invalid Flight Number", @"Invalid Flight Number");
            alertMessage = NSLocalizedString(@"Flight numbers are made up of an airline code and a number e.g.UA72. Don't know the airline code? We can look it up for you!",
                                             @"Airline Code Explanation");
            otherButtonTitle = NSLocalizedString(@"Lookup Airline Code", @"Lookup Airline Code");
            break;
        }
        case LookupErrorFlightNotFound: {
            alertTitle = [NSString stringWithFormat:NSLocalizedString(@"Flight %@ Not Found", @"Flight XYZ Not Found"), _flightNumberField.text];
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Unfortunately we don't have information for flight %@. We've recorded this missing flight and will try to add it in the future.",
                                                                        @"Flight not found."), _flightNumberField.text];
            // Reversed intentionally
            otherButtonTitle = NSLocalizedString(@"OK", @"OK");
            cancelButtonTitle = NSLocalizedString(@"More Info", @"More Info");
            break;
        }
        case LookupErrorNonexistentAirline: {
            NSArray *flightNumParts = [[self class] splitFlightNumber:_flightNumberField.text];
            NSString *airlineCode = ([flightNumParts count] == 2) ? [flightNumParts objectAtIndex:0] : _flightNumberField.text;
            alertTitle = NSLocalizedString(@"Unknown Airline Code", @"Unknown Airline Code");
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"We don't recognize airline code %@. Don't know the airline code? We can look it up for you!",
                                                                        @"Unknown Airline Code Explanation"), airlineCode];
            otherButtonTitle = NSLocalizedString(@"Lookup Airline Code", @"Lookup Airline Code");
            break;
        }
        case LookupErrorNoCurrentFlight: {
            alertTitle = NSLocalizedString(@"Can't Track Flight Yet", @"No Current Flight");
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Flight %@ is not arriving in the next 48 hours. Please try again closer to the arrival date.",
                                                                        @"No Current Flight Explanantion"), _flightNumberField.text];
            // Reversed intentionally
            otherButtonTitle = NSLocalizedString(@"OK", @"OK");
            cancelButtonTitle = NSLocalizedString(@"More Info", @"More Info");
            break;
        }
        case LookupErrorFlightNumberMissingAirlineCode: {
            alertTitle = NSLocalizedString(@"Missing Airline Code", @"Missing Airline Code");
            alertMessage = NSLocalizedString(@"Flight numbers are made up of an airline code and a number e.g.UA72. Don't know the airline code? We can look it up for you!",
                                             @"Airline Code Explanation");
            otherButtonTitle = NSLocalizedString(@"Lookup Airline Code", @"Lookup Airline Code");
            break;
        }
        case LookupErrorOutage: {
            alertTitle = NSLocalizedString(@"Service Outage", @"Service Outage");
            alertMessage = NSLocalizedString(@"Just Landed is currently unavailable. Our engineers are working to restore service. Please try again later.",
                                             @"Service outage msg.");
            // Reversed intentionally
            otherButtonTitle = NSLocalizedString(@"OK", @"OK");
            cancelButtonTitle = NSLocalizedString(@"More Info", @"More Info");
            break;
        }
        case LookupErrorNoConnection: {
            alertTitle = NSLocalizedString(@"No Internet Connection", @"No Internet Connection");
            alertMessage = NSLocalizedString(@"Please check your wireless signal and try again.", @"Please check your connection.");
            cancelButtonTitle = NSLocalizedString(@"OK", @"OK");
            break;
        }
        case LookupErrorServerError: {
            alertTitle = NSLocalizedString(@"Server Error", @"Server Error");
            alertMessage = NSLocalizedString(@"An error has occurred. Our engineers have been notified. Please try again later.",
                                             @"Server error msg.");
            cancelButtonTitle = NSLocalizedString(@"OK", @"OK");
            break;
        }
        default:{
            return;
            break;
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitle, nil];
    alert.tag = errorType;
    [alert show];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    // Configure the main view
    UIImageView *mainView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    mainView.backgroundColor = [UIColor blackColor];
    mainView.image = [UIImage imageNamed:@"sky_bg"];
    mainView.userInteractionEnabled = YES;
    self.view = mainView;
    
    // Add the cloud layer
    self._cloudLayer = [[JLCloudLayer alloc] initWithFrame:CLOUD_LAYER_FRAME];
    self._cloudLayer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_cloudLayer];
    
    // Add the cloud footer
    UIImageView *cloudFooter = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"lookup_cloud_fg"]
                                                               resizableImageWithCapInsets:UIEdgeInsetsMake(9.0f, 9.0f, 9.0f, 9.0f)]];
    cloudFooter.frame = CLOUD_FOOTER_FRAME;
    cloudFooter.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:cloudFooter];
    
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
    self._airplane = [[JLAirplaneView alloc] initWithFrame:AIRPLANE_FRAME];
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
    [_airplane startAnimating];
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


- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)clearFlightNumberField {
    self._flightNumberField.text = @"";
    [self resetFlightInputKeyboard];
    [self disallowLookup];
}


- (void)resetFlightInputKeyboard {
    self._flightNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
    [self._flightNumberField.textInputView reloadInputViews];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self._flightResultsTable.hidden = YES;
    self._flightResultsTableFrame.hidden = YES;
    self._lookupButton.hidden = NO;
    self._airportCodesButton.hidden = NO;
    self._airportCodesLabelButton.hidden = NO;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearFlightNumberField];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Don't allow lookup if flight num is invalid or all digits
    if ([[self class] isFlightNumInteger:textField.text]) {
        [self alertWithError:LookupErrorFlightNumberMissingAirlineCode];
    }
    else {
        if ([[self class] isFlightNumValid:textField.text]) {
            [self doLookup];
        }
        else {
            [self alertWithError:LookupErrorInvalidFlightNumber];
        }
    }
    return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Force uppercase
    NSString *oldText = [[textField text] uppercaseString];
    NSString *newText = [[[textField text] stringByReplacingCharactersInRange:range withString:string] uppercaseString];
    BOOL colorTextAsError = NO;
    
    // Truncate after 9 chars
    if ([newText length] < 9) {
        [textField setText:newText];
    }
    
    // Enable/disable lookup button based on whether flight num is valid
    if ([[self class] isFlightNumValid:newText]) {        
        if ([[self class] isFlightNumInteger:textField.text]) {
            [self disallowLookup];
            colorTextAsError = YES;
        }
        else {
            [self allowLookup];
        }
            
        // If the airline code is there but doesn't exist, color the text red
        if (![[self class] flightNumContainsValidAirlineCode:newText]) {
            colorTextAsError = YES;
        }
    }
    else {
        [self disallowLookup];
        
        // If they've typed enough characters for a valid flight num, and it's still not valid, color red
        if ([[[self class] sanitizedFlightNum:newText] length] >= 4) {
            colorTextAsError = YES;
        }
    }
    
    // Show appropriate keyboard if they deleted text, depending on what they deleted
    if ([newText length] < [oldText length]) {
        // Figure out if the last character they deleted was a letter or digit
        if (![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[oldText characterAtIndex:[newText length]]]) {
            [self resetFlightInputKeyboard];
        }
    }
    
    // Color the text red or normal
    self._flightNumberField.errorState = colorTextAsError ? FlightInputError : FlightInputNoError;

    return NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case LookupErrorInvalidFlightNumber:
        case LookupErrorNonexistentAirline:
        case LookupErrorFlightNumberMissingAirlineCode: {
            [self clearFlightNumberField];
            [_flightNumberField becomeFirstResponder];
            [self lookupCodes];
            break;
        }
        case LookupErrorFlightNotFound:
        case LookupErrorNoCurrentFlight: {
            // Keep their input
            [_flightNumberField becomeFirstResponder];
            
            if ([alertView cancelButtonIndex] == buttonIndex) {
                // TODO: They want to see more info... (we're using cancel as more info)
                NSString *title = nil;
                NSURL *url = nil;
                
                switch (alertView.tag) {
                    case LookupErrorFlightNotFound: {
                        title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, FNF_ANCHOR]];
                        [FlurryAnalytics logEvent:FY_READ_FAQ];
                        break;
                    }
                    default: {
                        title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, HRS48_ANCHOR]];
                        [FlurryAnalytics logEvent:FY_READ_FAQ];
                        break;
                    }
                }
                
                WebContentViewController *webContentVC = [[WebContentViewController alloc] initWithContentTitle:title URL:url];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webContentVC];
                navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                webContentVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                                                  style:UIBarButtonItemStylePlain
                                                                                                 target:self
                                                                                                 action:@selector(dismissVC)];
                [self presentModalViewController:navController animated:YES];
            }
            break;
        }
        case LookupErrorOutage: {
            if ([alertView cancelButtonIndex] == buttonIndex) {
                // TODO: They want to see more info... (we're using cancel as more info)
                [FlurryAnalytics logEvent:FY_VISITED_OPS_FEED];
                
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:NATIVE_TWITTER_JL_OPS]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NATIVE_TWITTER_JL_OPS]];
                }
                else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_JL_OPS]];
                }
            }
        }
        case LookupErrorNoConnection:
        case LookupErrorServerError:
        default: {
            // Keep their input
            [_flightNumberField becomeFirstResponder];
            break;
        }
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
    if (indexPath.row == (NSInteger)[self._flightResults count] - 1) {
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
    [_airplane startAnimating];
    
    // If the user stopped tracking, pre-fill the field with the flight they were tracking
    if (userFlag) {
        self._flightNumberField.text = aFlight.flightNumber;
        [FlurryAnalytics logEvent:FY_STOPPED_TRACKING_FLIGHT 
                   withParameters:[NSDictionary dictionaryWithObject:(aFlight.status == LANDED) ? @"YES" : @"NO"
                                                              forKey:@"Flight Landed"]];
    }
    else {
        // Probably an old flight, clear the field
        [self clearFlightNumberField];
    }
    
    // Enable / disable lookup as appropriate
    if ([[self class] isFlightNumValid:_flightNumberField.text]) {
        [self allowLookup];
    }
    else {
        [self disallowLookup];
    }
        
    [[JustLandedSession sharedSession] removeTrackedFlight:aFlight];
    [aFlight stopTracking];
    [self._flightNumberField becomeFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - AirlineLookupDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didChooseAirlineCode:(NSString *)airlineCode {
    [self disallowLookup];
    self._flightNumberField.text = airlineCode;
    self._flightNumberField.errorState = FlightInputNoError;
    [self resetFlightInputKeyboard];
    [self._flightNumberField becomeFirstResponder];
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
    [_airplane stopAnimating];
}

@end
