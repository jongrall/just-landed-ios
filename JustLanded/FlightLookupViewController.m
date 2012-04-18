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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FlightLookupViewController ()

@property (strong, nonatomic) UIButton *_lookupButton;
@property (strong, nonatomic) UITextField *_flightNumberField;
@property (strong, nonatomic) UITableView *_flightResultsTable;
@property (strong, nonatomic) UIActivityIndicatorView *_lookupSpinner;
@property (strong, nonatomic) NSArray *_flightResults;

- (void)flightLookupFailed:(NSNotification *)notification;
- (void)willLookupFlight:(NSNotification *)notification;
- (void)didLookupFlight:(NSNotification *)notification;
- (void)doLookup;
- (void)indicateLookingUp;
- (void)indicateStoppedLookingUp;
- (BOOL)isFlightNumValid:(NSString *)flightNum;
- (void)showAboutScreen;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FlightLookupViewController

@synthesize _lookupButton;
@synthesize _flightNumberField;
@synthesize _flightResultsTable;
@synthesize _lookupSpinner;
@synthesize _flightResults;

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
    self._lookupButton.enabled = YES; //FIXME
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
                                                            message:@"Please check that you entered your flight number correctly."
                                                           delegate:self 
                                                  cancelButtonTitle:@"Try Again"
                                                  otherButtonTitles:nil];
            [alert show];
            break;   
        }
        case LookupFailureFlightNotFound: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Flight Not Found", @"Flight Not Found") 
                                                            message:@"Please check that you entered your flight number correctly."
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }
        default: {
            [_flightNumberField becomeFirstResponder];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Flight Not Found", @"Flight Not Found") 
                                                            message:@"Just Landed can only track U.S. domestic flights that are arriving within the next 48 hours."
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK"
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
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    mainView.backgroundColor = [UIColor grayColor];
    self.view = mainView;
    
    // Add the title label
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 280.0f, 50.0f)];
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:30.0f];
    title.textColor = [UIColor blackColor];
    title.text = NSLocalizedString(@"Just Landed", @"Just Landed");
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];
    
    // Add the help button
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [helpButton addTarget:self action:@selector(showAboutScreen) forControlEvents:UIControlEventTouchUpInside];
    [helpButton setFrame:CGRectMake(260.0f, 20.0f, 50.0f, 50.0f)];
    [self.view addSubview:helpButton];
    
    // Add the input field label
    UILabel *flightNumFieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 102.0f, 100.0f, 40.0f)];
    flightNumFieldLabel.textAlignment = UITextAlignmentRight;
    flightNumFieldLabel.font = [UIFont systemFontOfSize:20.0f];
    flightNumFieldLabel.textColor = [UIColor blackColor];
    flightNumFieldLabel.text = NSLocalizedString(@"Flight #", @"Flight #");
    flightNumFieldLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:flightNumFieldLabel];
    
    // Add the input field
    UITextField *flightNumField = [[UITextField alloc] initWithFrame:CGRectMake(130.0f, 100.0f, 170.0f, 40.0f)];
    flightNumField.delegate = self;
    flightNumField.placeholder = NSLocalizedString(@"ex. AA320", 
                                                   @"Flight number input placeholder");
    flightNumField.textAlignment = UITextAlignmentLeft;
    flightNumField.borderStyle = UITextBorderStyleRoundedRect;
    flightNumField.font = [UIFont systemFontOfSize:26.0f];
    flightNumField.textColor = [UIColor blackColor];
    flightNumField.clearsOnBeginEditing = NO;
    flightNumField.clearButtonMode = UITextFieldViewModeWhileEditing;
    flightNumField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    flightNumField.autocorrectionType = UITextAutocorrectionTypeNo;
    flightNumField.spellCheckingType = UITextSpellCheckingTypeNo;
    flightNumField.keyboardType = UIKeyboardTypeNamePhonePad;
    self._flightNumberField = flightNumField;
    [self.view addSubview:flightNumField];
    
    // Add the lookup button
    UIButton *lookupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lookupButton.frame = CGRectMake(20.0f, 160.0f, 280.0f, 60.0f);
    [lookupButton setTitle:NSLocalizedString(@"Lookup Flight", @"Lookup Flight") forState:UIControlStateNormal];
    [lookupButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [lookupButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    lookupButton.titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    lookupButton.enabled = [self isFlightNumValid:_flightNumberField.text];
    [lookupButton addTarget:self action:@selector(doLookup) forControlEvents:UIControlEventTouchUpInside];
    self._lookupButton = lookupButton;
    [self.view addSubview:lookupButton];
    
    // Add the results table
    UITableView *resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(20.0f, 
                                                                              180.0f, 
                                                                              FlightResultTableViewCellWidth, 
                                                                              250.0f) 
                                                             style:UITableViewStylePlain];
    resultsTable.dataSource = self;
    resultsTable.delegate = self;
    resultsTable.rowHeight = FlightResultTableViewCellHeight;
    resultsTable.hidden = YES;
    self._flightResultsTable = resultsTable;
    [self.view addSubview:resultsTable];
    
    // Add the lookup spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                        UIActivityIndicatorViewStyleWhiteLarge];
    spinner.hidesWhenStopped = YES;
    spinner.frame = CGRectMake(160.0f - (spinner.frame.size.width / 2.0f),
                               260.0f,
                               spinner.frame.size.width,
                               spinner.frame.size.height);
    self._lookupSpinner = spinner;
    [self.view addSubview:_lookupSpinner];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self._flightNumberField = nil;
    self._flightResultsTable = nil;
    self._lookupSpinner = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Supports portrait only
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    self._flightNumberField.text = @"";
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
    }
    
    Flight *aFlight = [self._flightResults objectAtIndex:[indexPath row]];
    
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
            cell.landingTime = aFlight.detailedStatus;
            break;
        case DIVERTED:
        case CANCELED:
        case UNKNOWN:
            cell.landingTime = [NSString stringWithFormat:@"Not Arriving %@",
                           [NSDate naturalDateStringFromDate:[aFlight scheduledArrivalTime]]];
        default:
            cell.landingTime = [NSString stringWithFormat:@"Arrives %@",
                           [NSDate naturalDateStringFromDate:[aFlight scheduledArrivalTime]]];
            break;
    }
    
    // Display the status of the flight
    switch (aFlight.status) {
        case SCHEDULED:
            cell.statusColor = [UIColor grayColor];
            cell.status = NSLocalizedString(@"SCHEDULED", @"Scheduled");
            break;
        case ON_TIME:
        case EARLY:
        case DELAYED:
            if (aFlight.actualDepartureTime) {
                cell.statusColor = [UIColor yellowColor];
                cell.status = NSLocalizedString(@"EN ROUTE", @"En Route");
            }
            else {
                cell.statusColor = [UIColor grayColor];
                cell.status = NSLocalizedString(@"SCHEDULED", @"Scheduled");
            }
            break;
        case DIVERTED:
            cell.statusColor = [UIColor redColor];
            cell.status = NSLocalizedString(@"DIVERTED", @"Diverted");
            break;
        case CANCELED:
            cell.statusColor = [UIColor redColor];
            cell.status = NSLocalizedString(@"CANCELED", @"Canceled");
            break;
        case LANDED:
            cell.statusColor = [UIColor greenColor];
            cell.status = NSLocalizedString(@"LANDED", @"Landed");
            break;
        default:
            cell.statusColor = [UIColor grayColor];
            cell.status = @"";
            break;
    }
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self._flightResults count];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FlightTrackViewControllerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didFinishTracking:(FlightTrackViewController *)controller userInitiated:(BOOL)user_flag {
    self._flightResultsTable.hidden = YES;
    self._lookupButton.hidden = NO;
    
    // If the user stopped tracking, pre-fill the field with the flight they were tracking
    if (user_flag) {
        self._flightNumberField.text = controller.trackedFlight.flightNumber;
        [FlurryAnalytics logEvent:FY_STOPPED_TRACKING_FLIGHT 
                   withParameters:[NSDictionary dictionaryWithObject:(controller.trackedFlight.status == LANDED) ? @"YES" : @"NO"
                                                              forKey:@"Flight Landed"]];
    }
    else {
        // Probably an old flight, clear the field
        self._flightNumberField.text = @"";
    }
    
    self._lookupButton.enabled = [self isFlightNumValid:_flightNumberField.text];
    
    [self dismissModalViewControllerAnimated:YES];
    [[JustLandedSession sharedSession] removeTrackedFlight:controller.trackedFlight];
    
    // If they're no longer tracking any flights, stop location services and clear notifications
    if ([[[JustLandedSession sharedSession] currentlyTrackedFlights] count] == 0) {
        [[JustLandedSession sharedSession] stopLocationServices];
        
        // Clear past notifications
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
}

@end
