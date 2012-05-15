//
//  FlightLookupViewController.m
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
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
@property (strong, nonatomic) JLFlightInputField *_flightNumberField;
@property (strong, nonatomic) UITableView *_flightResultsTable;
@property (strong, nonatomic) UIImageView *_airplane;
@property (strong, nonatomic) UIImageView *_flightResultsTableFrame;
@property (strong, nonatomic) JLSpinner *_lookupSpinner;
@property (strong, nonatomic) NSTimer *_airplaneTimer;
@property (strong, nonatomic) NSArray *_flightResults;
@property (strong, nonatomic) JLCloudLayer *_cloudLayer;

- (void)flightLookupFailed:(NSNotification *)notification;
- (void)willLookupFlight:(NSNotification *)notification;
- (void)didLookupFlight:(NSNotification *)notification;
- (void)doLookup;
- (void)indicateLookingUp;
- (void)indicateStoppedLookingUp;
- (BOOL)isFlightNumValid:(NSString *)flightNum;
- (void)showAboutScreen;
- (void)animatePlane;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FlightLookupViewController

@synthesize _lookupButton;
@synthesize _flightNumberField;
@synthesize _flightResultsTable;
@synthesize _airplane;
@synthesize _flightResultsTableFrame;
@synthesize _lookupSpinner;
@synthesize _airplaneTimer;
@synthesize _flightResults;
@synthesize _cloudLayer;

static NSRegularExpression *_flightNumberRegex;


+ (void)initialize {
    if (self == [FlightLookupViewController class]) {
        NSError *error = NULL;
        _flightNumberRegex = [NSRegularExpression regularExpressionWithPattern:@"\\A[A-Z0-9]{2}[A-Z]{0,1}[0-9]{1,4}[A-Z]{0,1}\\Z"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:&error];
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
    self._lookupButton.enabled = NO;
    [_lookupSpinner startAnimating];
}


- (void)indicateStoppedLookingUp {
    [_lookupSpinner stopAnimating];
    self._flightNumberField.enabled = YES;
    self._lookupButton.enabled = [self isFlightNumValid:_flightNumberField.text];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)doLookup {
    NSString *flightNumber = [[[_flightNumberField text] uppercaseString] stringByReplacingOccurrencesOfString:@" " 
                                                                                                    withString:@""];
    if ([self isFlightNumValid:flightNumber]) {
        [_flightNumberField resignFirstResponder];
        [Flight lookupFlights:flightNumber];
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
        case LookupFailureFlightNotFound: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Flight %@ Not Found", @"Flight XYZ Not Found"),
                                                                     _flightNumberField.text]
                                                            message:NSLocalizedString(@"Please check that you entered your flight number correctly.",
                                                                                      @"Please check flight #")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            alert.tag = LookupFailureFlightNotFound;
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
                                                            message:NSLocalizedString(@"Just Landed can only track U.S. domestic flights that are arriving within the next 48 hours.",
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
    [self.view addSubview:_cloudLayer];
    
    // Add the cloud foreground
    UIImageView *cloudFg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lookup_cloud_fg"]];
    cloudFg.frame = CLOUD_FOOTER_FRAME;
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
    self._flightNumberField = flightNumField;
    
    UIImageView *lookupInputContainer = [[UIImageView alloc] initWithFrame:LOOKUP_INPUT_FRAME];
    lookupInputContainer.image = [[UIImage imageNamed:@"lookup_input_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)];
    lookupInputContainer.userInteractionEnabled = YES;
    [lookupInputContainer addSubview:flightNumField];
    [self.view addSubview:lookupInputContainer];
    
    // Add the lookup button
    JLButton *lookupButton = [[JLButton alloc] initWithButtonStyle:[JLLookupStyles lookupButtonStyle] frame:LOOKUP_BUTTON_FRAME];
    [lookupButton setTitle:NSLocalizedString(@"Lookup Flight", @"Lookup Flight") forState:UIControlStateNormal];
    lookupButton.enabled = [self isFlightNumValid:_flightNumberField.text];
    [lookupButton addTarget:self action:@selector(doLookup) forControlEvents:UIControlEventTouchUpInside];
    self._lookupButton = lookupButton;
    [self.view addSubview:lookupButton];
    
    // Add the results table
    UITableView *resultsTable = [[UITableView alloc] initWithFrame:RESULTS_TABLE_FRAME style:UITableViewStylePlain];
    resultsTable.backgroundColor = [UIColor clearColor];
    resultsTable.layer.cornerRadius = 6.0f;
    resultsTable.layer.masksToBounds = YES;
    resultsTable.dataSource = self;
    resultsTable.delegate = self;
    resultsTable.rowHeight = FlightResultTableViewCellHeight;
    resultsTable.hidden = YES;
    resultsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    resultsTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    resultsTable.scrollIndicatorInsets = UIEdgeInsetsMake(2.0f, 0.0f, 2.0f, 2.0f);
    self._flightResultsTable = resultsTable;
    [self.view addSubview:resultsTable];
    
    // Add the airplane
    _airplane = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plane_contrail"]];
    _airplane.frame = CGRectMake(-_airplane.frame.size.width, // Place offscreen
                                 85.0f,
                                 _airplane.frame.size.width,
                                 _airplane.frame.size.height);
    [self.view addSubview:_airplane];
    
    // Add the table frame
    UIImage *tableFrame = [[UIImage imageNamed:@"table_frame"] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0f, 11.0f, 11.0f, 11.0f)];
    self._flightResultsTableFrame = [[UIImageView alloc] initWithImage:tableFrame];
    self._flightResultsTableFrame.frame = RESULTS_TABLE_CONTAINER_FRAME;
    [self.view addSubview:_flightResultsTableFrame];
    
    // Add the lookup spinner
    _lookupSpinner = [[JLSpinner alloc] initWithFrame:CGRectMake(103.0f, 278.0f, 114.0f, 115.0f)];
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


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)isFlightNumValid:(NSString *)flightNum {
    if (flightNum == nil) {
        return NO;
    }
    
    NSString *sanitizedNum = [[flightNum uppercaseString] stringByReplacingOccurrencesOfString:@" " 
                                                                                    withString:@""];
    NSUInteger numMatches = [_flightNumberRegex numberOfMatchesInString:sanitizedNum 
                                                                options:0 
                                                                  range:NSMakeRange(0, [sanitizedNum length])];
    return (numMatches == 1) ? YES : NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self._flightResultsTable.hidden = YES;
    self._flightResultsTableFrame.hidden = YES;
    self._lookupButton.hidden = NO;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self._lookupButton.enabled = NO;
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self isFlightNumValid:[_flightNumberField text]]) {
        [self doLookup];
    }
    return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Force uppercase
    NSString *newText = [[[textField text] stringByReplacingCharactersInRange:range withString:string] uppercaseString];
    
    if ([newText length] < 9) {
        [textField setText:newText];
    }
    
    // Enable/disable lookup button based on whether flight num is valid
    if ([self isFlightNumValid:newText]) {
        self._lookupButton.enabled = YES;
    }
    else {
        self._lookupButton.enabled = NO;
    }

    return NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == LookupFailureFlightNotFound || alertView.tag == LookupFailureInvalidFlightNumber) {
        // Clear the field only on bad flight # or flight number not found
        self._flightNumberField.text = @"";
        self._lookupButton.enabled = NO;
    }
    
    [self._flightNumberField becomeFirstResponder];
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FlightTrackViewControllerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didFinishTracking:(FlightTrackViewController *)controller userInitiated:(BOOL)user_flag {
    controller.delegate = nil;
    self._flightResultsTable.hidden = YES;
    self._flightResultsTableFrame.hidden = YES;
    self._lookupButton.hidden = NO;
    [_cloudLayer startAnimating]; // Begin animating the cloud layer
    [self startAnimatingPlane];
    
    Flight *flight = controller.trackedFlight;
    
    // If the user stopped tracking, pre-fill the field with the flight they were tracking
    if (user_flag) {
        self._flightNumberField.text = flight.flightNumber;
        [FlurryAnalytics logEvent:FY_STOPPED_TRACKING_FLIGHT 
                   withParameters:[NSDictionary dictionaryWithObject:(flight.status == LANDED) ? @"YES" : @"NO"
                                                              forKey:@"Flight Landed"]];
    }
    else {
        // Probably an old flight, clear the field
        self._flightNumberField.text = @"";
    }
    
    self._lookupButton.enabled = [self isFlightNumValid:_flightNumberField.text];
        
    [[JustLandedSession sharedSession] removeTrackedFlight:flight];
    [flight stopTracking];
    
    // If they're no longer tracking any flights, stop location services
    if ([[[JustLandedSession sharedSession] currentlyTrackedFlights] count] == 0) {
        [[JustLandedSession sharedSession] stopLocationServices];
        
        // Clear past notifications from the notification center
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }

    [self._flightNumberField becomeFirstResponder];
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
