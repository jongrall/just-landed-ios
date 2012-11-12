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

// Redefine as readwrite
@property (strong, readwrite, nonatomic) JLFlightInputField *flightNumberField;

@property (strong, nonatomic) JLButton *lookupButton_;
@property (strong, nonatomic) JLButton *airportCodesButton_;
@property (strong, nonatomic) JLButton *airportCodesLabelButton_;
@property (strong, nonatomic) UITableView *flightResultsTable_;
@property (strong, nonatomic) JLAirplaneView *airplane_;
@property (strong, nonatomic) UIImageView *flightResultsTableFrame_;
@property (strong, nonatomic) JLSpinner *lookupSpinner_;
@property (strong, nonatomic) NSArray *flightResults_;
@property (strong, nonatomic) JLCloudLayer *cloudLayer_;

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

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FlightLookupViewController

@synthesize flightNumberField = flightNumberField_;
@synthesize flightResultsTable_;
@synthesize airplane_;
@synthesize cloudLayer_;

static NSRegularExpression *sFlightNumberRegex_;
static NSRegularExpression *sAirlineCodeRegex_;


+ (void)initialize {
    static dispatch_once_t sOncePredicate;
    
    if (self == [FlightLookupViewController class]) {
        dispatch_once(&sOncePredicate, ^{
        NSError *error = NULL;
            sFlightNumberRegex_ = [NSRegularExpression regularExpressionWithPattern:@"\\A[A-Z0-9]{2}[A-Z]{0,1}[0-9]{1,4}[A-Z]{0,1}\\Z"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:&error];
            sAirlineCodeRegex_ = [NSRegularExpression regularExpressionWithPattern:@"\\A[A-Z][0-9][A-Z]{0,1}|\\A[0-9][A-Z]{1,2}|\\A[A-Z]{2,3}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
        });
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
    NSUInteger numMatches = [sFlightNumberRegex_ numberOfMatchesInString:sanitizedNum
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
        NSTextCheckingResult *result = [sAirlineCodeRegex_ firstMatchInString:sanitizedNum
                                                                     options:NSMatchingAnchored
                                                                       range:NSMakeRange(0, [sanitizedNum length])];
        if (result.range.location != NSNotFound) {
            return @[[sanitizedNum substringWithRange:result.range],
                    [sanitizedNum substringFromIndex:result.range.length]];
        }
        else {
            // Unable to split - no valid airline code
            return @[sanitizedNum];
        }
    }
    else {
        return @[];
    }
}


+ (BOOL)flightNumContainsValidAirlineCode:(NSString *)flightNum {
    NSArray *parts = [[self class] splitFlightNumber:flightNum];
    if ([parts count] == 2 && [AirlineLookupViewController airlineCodeExists:parts[0]]) {
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
    [self.cloudLayer_ stopAnimating]; // Stop animating the clouds
    [self.airplane_ stopAnimating];
    [self presentViewController:controller animated:animateFlip completion:NULL];
    
    // If animated, was user-initiated, record the track
    if (animateFlip) {
        [[JustLandedSession sharedSession] incrementTrackCount];
        
        [Flurry logEvent:FY_BEGAN_TRACKING_FLIGHT 
                   withParameters:@{@"Minutes Before Landing": [NSString stringWithFormat:@"%d", [aFlight minutesBeforeLanding]]}];
        
    }
}


- (void)indicateLookingUp {
    self.flightNumberField.enabled = NO;
    self.lookupButton_.hidden = YES;
    self.airportCodesButton_.hidden = YES;
    self.airportCodesLabelButton_.hidden = YES;
    [self.lookupSpinner_ startAnimating];
}


- (void)indicateStoppedLookingUp {
    [self.lookupSpinner_ stopAnimating];
    self.flightNumberField.enabled = YES;
    
    self.lookupButton_.hidden = NO;
    self.airportCodesButton_.hidden = NO;
    self.airportCodesLabelButton_.hidden = NO;
    
    if ([[self class] isFlightNumValid:self.flightNumberField.text]) {
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
    [self.flightNumberField resignFirstResponder];
    [Flight lookupFlights:[[self class] sanitizedFlightNum:self.flightNumberField.text]];
}


- (void)lookupCodes {
    AirlineLookupViewController *airlineLookupVC = [[AirlineLookupViewController alloc] init];
    airlineLookupVC.delegate = self;
    UINavigationController *airlineLookupNavVC = [[UINavigationController alloc] initWithRootViewController:airlineLookupVC];
    airlineLookupNavVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:airlineLookupNavVC animated:YES completion:NULL];
    [Flurry logEvent:FY_BEGAN_AIRLINE_LOOKUP];
}


- (void)showAboutScreen {
    AboutViewController *aboutController = [[AboutViewController alloc] init];
    aboutController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // HACK: Causes loadview to fire, which causes offsetting clouds before animation to work, and adds airplane to aboutController view
    aboutController.airplane = self.airplane_;
    aboutController.cloudLayer.currentCloudOffsets = self.cloudLayer_.currentCloudOffsets;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController
                       animated:NO // Instant transition
                     completion:^{
                         [aboutController revealContent];
                     }];
    [Flurry logEvent:FY_VISITED_ABOUT_SCREEN];
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
            if ([[self class] isFlightNumInteger:self.flightNumberField.text]) {
                // They've entered all numbers - not understanding desired input
                [self alertWithError:LookupErrorFlightNumberMissingAirlineCode];
            }
            else if (![[self class] flightNumContainsValidAirlineCode:self.flightNumberField.text]) {
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
        self.flightResults_ = flights;
    
        if ([flights count] == 0) {
            [self alertWithError:LookupErrorFlightNotFound];
        }
        else if ([flights count] == 1) {
            [self beginTrackingFlight:flights[0] animated:YES];
        }
        else {
            [self.flightResultsTable_ reloadData];
            [self.flightResultsTable_ setContentOffset:CGPointZero];
            self.lookupButton_.hidden = YES;
            self.airportCodesButton_.hidden = YES;
            self.airportCodesLabelButton_.hidden = YES;
            self.flightResultsTable_.hidden = NO;
            self.flightResultsTableFrame_.hidden = NO;
        }
    
        [Flurry logEvent:FY_LOOKED_UP_FLIGHT 
                   withParameters:@{@"Number Of Results": [NSString stringWithFormat:@"%d", [flights count]]}];
    }
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
            alertTitle = [NSString stringWithFormat:NSLocalizedString(@"Flight %@ Not Found", @"Flight XYZ Not Found"),
                          self.flightNumberField.text];
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Unfortunately we don't have information for flight %@. We've recorded this missing flight and will try to add it in the future.",
                                                                        @"Flight not found."), self.flightNumberField.text];
            // Reversed intentionally
            otherButtonTitle = NSLocalizedString(@"OK", @"OK");
            cancelButtonTitle = NSLocalizedString(@"More Info", @"More Info");
            break;
        }
        case LookupErrorNonexistentAirline: {
            NSArray *flightNumParts = [[self class] splitFlightNumber:self.flightNumberField.text];
            NSString *airlineCode = ([flightNumParts count] == 2) ? flightNumParts[0] : self.flightNumberField.text;
            alertTitle = NSLocalizedString(@"Unknown Airline Code", @"Unknown Airline Code");
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"We don't recognize airline code %@. Don't know the airline code? We can look it up for you!",
                                                                        @"Unknown Airline Code Explanation"), airlineCode];
            otherButtonTitle = NSLocalizedString(@"Lookup Airline Code", @"Lookup Airline Code");
            break;
        }
        case LookupErrorNoCurrentFlight: {
            alertTitle = NSLocalizedString(@"Can't Track Flight Yet", @"No Current Flight");
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Flight %@ is not arriving in the next 48 hours. Please try again closer to the arrival date.",
                                                                        @"No Current Flight Explanantion"), self.flightNumberField.text];
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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIImageView *mainView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                          0.0f,
                                                                          screenBounds.size.width,
                                                                          screenBounds.size.height - 20.0f)]; // Status bar
    mainView.backgroundColor = [UIColor blackColor];
    mainView.image = [UIImage imageNamed:[@"sky_bg" imageName]];
    mainView.userInteractionEnabled = YES;
    self.view = mainView;
    
    // Add the cloud layer
    self.cloudLayer_ = [[JLCloudLayer alloc] initWithFrame:[JLLookupStyles cloudLayerFrame]];
    self.cloudLayer_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.cloudLayer_];
    
    // Add the cloud footer
    UIImageView *cloudFooter = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"lookup_cloud_fg"]
                                                               resizableImageWithCapInsets:UIEdgeInsetsMake(9.0f, 9.0f, 9.0f, 9.0f)]];
    cloudFooter.frame = [JLLookupStyles cloudFooterFrame];
    cloudFooter.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:cloudFooter];
    
    // Add the logo
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    logo.frame = [JLLookupStyles logoFrame];
    if ([UIScreen isMainScreenWide]) {
        logo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    [self.view addSubview:logo];
    
    // Add the about button
    JLButton *aboutButton = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles aboutButtonStyle]
                                                            frame:[JLLookupStyles aboutButtonFrame]];
    [aboutButton addTarget:self action:@selector(showAboutScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutButton];
    
    // Add the input field
    JLFlightInputField *flightNumField = [[JLFlightInputField alloc] initWithFrame:[JLLookupStyles lookupTextFieldFrame]];
    flightNumField.delegate = self;
    flightNumField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.flightNumberField = flightNumField;
    
    UIImageView *lookupInputContainer = [[UIImageView alloc] initWithFrame:[JLLookupStyles lookupInputFrame]];
    lookupInputContainer.image = [[UIImage imageNamed:@"lookup_input_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)];
    lookupInputContainer.userInteractionEnabled = YES;
    [lookupInputContainer addSubview:flightNumField];
    lookupInputContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:lookupInputContainer];
    
    // Add the airport codes button and the airport codes label
    self.airportCodesLabelButton_ = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles airportCodesLabelButtonStyle]
                                                                    frame:[JLLookupStyles airportCodesLabelFrame]];
    [self.airportCodesLabelButton_ setTitle:NSLocalizedString(@"Don't know the airline code?", @"Airline Lookup Prompt")
                              forState:UIControlStateNormal];
    self.airportCodesLabelButton_.alpha = [[self class] isFlightNumValid:self.flightNumberField.text] ? 0.0f : 1.0f;
    [self.airportCodesLabelButton_ addTarget:self action:@selector(lookupCodes) forControlEvents:UIControlEventTouchUpInside];
    self.airportCodesLabelButton_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.airportCodesLabelButton_];
    
    self.airportCodesButton_ = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles airportCodesButtonStyle]
                                                               frame:[JLLookupStyles airportCodesButtonFrame]];
    self.airportCodesButton_.alpha = [[self class] isFlightNumValid:self.flightNumberField.text] ? 0.0f : 1.0f;
    [self.airportCodesButton_ addTarget:self action:@selector(lookupCodes) forControlEvents:UIControlEventTouchUpInside];
    self.airportCodesButton_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.airportCodesButton_];
    
    // Add the lookup button
    JLButton *lookupButton = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles lookupButtonStyle]
                                                             frame:[JLLookupStyles lookupButtonFrame]];
    [lookupButton setTitle:NSLocalizedString(@"Find Flight", @"Find Flight") forState:UIControlStateNormal];
    lookupButton.alpha = [[self class] isFlightNumValid:self.flightNumberField.text] ? 1.0f : 0.0f;
    [lookupButton addTarget:self action:@selector(doLookup) forControlEvents:UIControlEventTouchUpInside];
    lookupButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lookupButton_ = lookupButton;
    [self.view addSubview:lookupButton];
    
    // Add the results table
    UITableView *resultsTable = [[UITableView alloc] initWithFrame:[JLLookupStyles resultsTableFrame]
                                                             style:UITableViewStylePlain];
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
    self.flightResultsTable_ = resultsTable;
    [self.view addSubview:resultsTable];
    
    // Add the airplane
    self.airplane_ = [[JLAirplaneView alloc] initWithFrame:[JLLookupStyles airplaneFrame]];
    [self.view addSubview:self.airplane_];
    
    // Add the table frame
    UIImage *tableFrame = [[UIImage imageNamed:@"table_frame"] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0f, 11.0f, 11.0f, 11.0f)];
    self.flightResultsTableFrame_ = [[UIImageView alloc] initWithImage:tableFrame];
    self.flightResultsTableFrame_.frame = [JLLookupStyles resultsTableContainerFrame];
    self.flightResultsTableFrame_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.flightResultsTableFrame_];
    
    // Add the lookup spinner
    self.lookupSpinner_ = [[JLSpinner alloc] initWithFrame:[JLLookupStyles lookupSpinnerFrame]];
    self.lookupSpinner_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.lookupSpinner_];
}


- (void)viewDidLoad {
    [self.cloudLayer_ startAnimating];
    [self.airplane_ startAnimating];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.lookupButton_ = nil;
    self.airportCodesButton_ = nil;
    self.airportCodesLabelButton_ = nil;
    self.flightNumberField = nil;
    self.flightResultsTable_ = nil;
    self.flightResultsTableFrame_ = nil;
    self.lookupSpinner_ = nil;
    self.airplane_ = nil;
    self.cloudLayer_ = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Supports portrait only
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)allowLookup {
    self.lookupButton_.enabled = YES;
    self.airportCodesButton_.enabled = NO;
    self.airportCodesLabelButton_.enabled = NO;
    
    [UIView animateWithDuration:0.125
                          delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         self.airportCodesButton_.alpha = 0.0f;
                         self.airportCodesLabelButton_.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.125 
                                               delay:0.0 
                                             options:UIViewAnimationOptionBeginFromCurrentState 
                                          animations:^{
                                              self.lookupButton_.alpha = 1.0f;
                                          }
                                          completion:NULL];
                     }];
}


- (void)disallowLookup {
    self.lookupButton_.enabled = NO;
    self.airportCodesButton_.enabled = YES;
    self.airportCodesLabelButton_.enabled = YES;
    
    [UIView animateWithDuration:0.125 
                          delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         self.lookupButton_.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.125 
                                               delay:0.0 
                                             options:UIViewAnimationOptionBeginFromCurrentState 
                                          animations:^{
                                              self.airportCodesButton_.alpha = 1.0f;
                                              self.airportCodesLabelButton_.alpha = 1.0f;
                                          }
                                          completion:NULL];
                     }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)clearFlightNumberField {
    self.flightNumberField.text = @"";
    [self resetFlightInputKeyboard];
    [self disallowLookup];
}


- (void)resetFlightInputKeyboard {
    self.flightNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
    [self.flightNumberField.textInputView reloadInputViews];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.flightResultsTable_.hidden = YES;
    self.flightResultsTableFrame_.hidden = YES;
    self.lookupButton_.hidden = NO;
    self.airportCodesButton_.hidden = NO;
    self.airportCodesLabelButton_.hidden = NO;
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
    self.flightNumberField.errorState = colorTextAsError ? FlightInputError : FlightInputNoError;

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
            [self.flightNumberField becomeFirstResponder];
            [self lookupCodes];
            break;
        }
        case LookupErrorFlightNotFound:
        case LookupErrorNoCurrentFlight: {
            // Keep their input
            [self.flightNumberField becomeFirstResponder];
            
            if ([alertView cancelButtonIndex] == buttonIndex) {
                // TODO: They want to see more info... (we're using cancel as more info)
                NSString *title = nil;
                NSURL *url = nil;
                
                switch (alertView.tag) {
                    case LookupErrorFlightNotFound: {
                        title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, FNF_ANCHOR]];
                        [Flurry logEvent:FY_READ_FAQ];
                        break;
                    }
                    default: {
                        title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", WEB_HOST, FAQ_PATH, HRS48_ANCHOR]];
                        [Flurry logEvent:FY_READ_FAQ];
                        break;
                    }
                }
                
                WebContentViewController *webContentVC = [[WebContentViewController alloc] initWithContentTitle:title URL:url showDoneButton:YES];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webContentVC];
                navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [self presentViewController:navController animated:YES completion:NULL];
            }
            break;
        }
        case LookupErrorOutage: {
            if ([alertView cancelButtonIndex] == buttonIndex) {
                // TODO: They want to see more info... (we're using cancel as more info)
                [Flurry logEvent:FY_VISITED_OPS_FEED];
                
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
            [self.flightNumberField becomeFirstResponder];
            break;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource & UITableViewDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Flight *chosenFlight = (self.flightResults_)[[indexPath row]];
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
    
    Flight *aFlight = (self.flightResults_)[[indexPath row]];
    
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
    return [self.flightResults_ count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == (NSInteger)[self.flightResults_ count] - 1) {
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
    self.flightResultsTable_.hidden = YES;
    self.flightResultsTableFrame_.hidden = YES;
    self.lookupButton_.hidden = NO;
    self.airportCodesButton_.hidden = NO;
    self.airportCodesLabelButton_.hidden = NO;
    [self.cloudLayer_ startAnimating]; // Begin animating the cloud layer
    [self.airplane_ startAnimating];
    
    // If the user stopped tracking, pre-fill the field with the flight they were tracking
    if (userFlag) {
        self.flightNumberField.text = aFlight.flightNumber;
        [Flurry logEvent:FY_STOPPED_TRACKING_FLIGHT 
                   withParameters:@{@"Flight Landed": (aFlight.status == LANDED) ? @"YES" : @"NO"}];
    }
    else {
        // Probably an old flight, clear the field
        [self clearFlightNumberField];
    }
    
    // Enable / disable lookup as appropriate
    if ([[self class] isFlightNumValid:self.flightNumberField.text]) {
        [self allowLookup];
    }
    else {
        [self disallowLookup];
    }
        
    [[JustLandedSession sharedSession] removeTrackedFlight:aFlight];
    [aFlight stopTracking];
    [self.flightNumberField becomeFirstResponder];
    [self dismissViewControllerAnimated:userFlag completion:NULL]; // Animate if user-initiated
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - AirlineLookupDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didChooseAirlineCode:(NSString *)airlineCode {
    [self disallowLookup];
    self.flightNumberField.text = airlineCode;
    self.flightNumberField.errorState = FlightInputNoError;
    [self resetFlightInputKeyboard];
    [self.flightNumberField becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)cancelledAirlineLookup {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [Flurry logEvent:FY_CANCELED_AIRLINE_LOOKUP];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    flightNumberField_.delegate = nil;
    flightResultsTable_.delegate = nil;
    [cloudLayer_ stopAnimating];
    [airplane_ stopAnimating];
}

@end
