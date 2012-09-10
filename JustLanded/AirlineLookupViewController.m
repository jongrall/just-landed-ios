//
//  AirlineLookupViewController.m
//  Just Landed
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "AirlineLookupViewController.h"
#import "AirlineResultTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface AirlineLookupViewController ()

@property (strong, nonatomic) NSArray *airlines_;
@property (strong, nonatomic) JLLabel *noResultsLabel_;
@property (strong, nonatomic) UISearchBar *searchBar_;
@property (strong, nonatomic) UITableView *resultsTable_;

- (void)keyboardWasShown:(NSNotification *)notification;
- (NSString *)airlineCode:(NSDictionary *)airlineInfo;

@end


@implementation AirlineLookupViewController

@synthesize airlines_;

static NSArray *sAllAirlines_;

+ (void)initialize {
    static dispatch_once_t sOncePredicate;
        
    if (self == [AirlineLookupViewController class]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *allAirlines = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"airlines" ofType:@"plist"]];
            dispatch_once(&sOncePredicate, ^{    
                sAllAirlines_ = allAirlines;
            });
        });
    }
}


+ (BOOL)airlineCodeExists:(NSString *)aCode {
    for (id airline in sAllAirlines_) {
        if ([airline isKindOfClass:[NSDictionary class]]) {
            NSString *iataCode = [airline objectForKeyOrNil:@"iata"];
            NSString *icaoCode = [airline objectForKeyOrNil:@"icao"];
            
            if ([iataCode length] > 0 && [iataCode isEqualToString:aCode]) {
                return YES;
            }
            else if ([icaoCode length] > 0 && [icaoCode isEqualToString:aCode]) {
                return YES;
            }
        }
    }
    
    return NO;
}


- (id)init {
    self = [super init];
    
    if (self) {
        airlines_ = [[JustLandedSession sharedSession] recentlyLookedUpAirlines];
        
        if ([airlines_ count] > 0) {
            NSMutableArray *airlinesWithClear = [[NSMutableArray alloc] initWithArray:airlines_];
            [airlinesWithClear addObject:@"Clear Recent"];
            airlines_ = airlinesWithClear;
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    mainView.backgroundColor = [UIColor whiteColor];
    self.view = mainView;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    searchBar.placeholder = NSLocalizedString(@"Airline name e.g. 'Virgin'", @"Airline name prompt");
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.delegate = self;

    UIImage *bgImage = [[UIImage imageNamed:@"query_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f)];
    [[UISearchBar appearance] setBackgroundImage:bgImage];
    UIImage *fieldBg = [[UIImage imageNamed:@"query_field"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:fieldBg forState:UIControlStateNormal];
    [[UISearchBar appearance] setSearchTextPositionAdjustment:UIOffsetMake(0.0f, 2.0f)];
    
    for (UIView *subview in [searchBar subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)subview;
            [field setFont:[JLStyles sansSerifLightBoldOfSize:18.0f]];
        }
    }
    
    self.searchBar_ = searchBar;
    [self.view addSubview:searchBar];
    
    self.resultsTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, self.view.frame.size.height - self.searchBar_.frame.size.height)
                                                      style:UITableViewStylePlain];
    self.resultsTable_.delegate = self;
    self.resultsTable_.dataSource = self;
    self.resultsTable_.rowHeight = AirlineResultCellHeight;
    self.resultsTable_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.resultsTable_.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.resultsTable_];
    
    self.noResultsLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLLookupStyles noAirlineResultsLabel] frame:AIRLINE_NO_RESULTS_LABEL_FRAME];
    self.noResultsLabel_.text = NSLocalizedString(@"No Matching Airlines :(", @"No Matching Airlines");
    [self.resultsTable_ addSubview:self.noResultsLabel_];
    self.noResultsLabel_.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationItem.title = NSLocalizedString(@"Airline Lookup", @"Airline Lookup");
    
    // Custom navbar shadow
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.navigationController.navigationBar.layer.shadowColor = [[UIColor clearColor] CGColor];
    self.navigationController.navigationBar.layer.shadowOpacity = 0.0f;
	self.navigationController.navigationBar.layer.shadowRadius = 0.0f;
	self.navigationController.navigationBar.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self.navigationController.navigationBar bounds]] CGPath]; //Optimization avoids offscreen render pass
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") 
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self.delegate
                                                                             action:@selector(cancelledAirlineLookup)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWasShown:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
    
    [self.searchBar_ becomeFirstResponder];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Search Bar Delegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *oldTerm = [[searchBar text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *newTerm = [[[searchBar text] stringByReplacingCharactersInRange:range withString:text] 
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([newTerm length] < [oldTerm length] || ([newTerm length] == 1 && [oldTerm length] == 0)) {
        self.airlines_ = [sAllAirlines_ mutableCopy];
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *searchTerm = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *searchTermNoSpaces = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([searchTerm length] > 0) {
        NSMutableArray *matchingAirlines = [[NSMutableArray alloc] init];
        
        for (id airline in self.airlines_) {
            if ([airline isKindOfClass:[NSDictionary class]]) {
                NSString *airlineNameNoSpaces = [[airline objectForKeyOrNil:@"name"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([airlineNameNoSpaces rangeOfString:searchTermNoSpaces options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound) {
                    [matchingAirlines addObject:airline];
                }
            }
        }
        
        self.airlines_ = matchingAirlines;
    }
    else {
        self.airlines_ = [[JustLandedSession sharedSession] recentlyLookedUpAirlines];
        
        if ([self.airlines_ count] > 0) {
            NSMutableArray *airlinesWithClear = [[NSMutableArray alloc] initWithArray:self.airlines_];
            [airlinesWithClear addObject:@"Clear Recent"];
            self.airlines_ = airlinesWithClear;
        }
    }
    
    if ([self.airlines_ count] == 0 && [searchTerm length] > 0) {
        self.noResultsLabel_.hidden = NO;
    }
    else {
        self.noResultsLabel_.hidden = YES;
    }
        
    [self.resultsTable_ reloadData];
    [self.resultsTable_ setContentOffset:CGPointZero animated:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate & DataSource Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)airlineCode:(NSDictionary *)airlineInfo {
    NSString *iataCode = [airlineInfo valueForKeyOrNil:@"iata"];
    NSString *icaoCode = [airlineInfo valueForKeyOrNil:@"icao"];
    
    // First choice: IATA code without numbers
    if ([iataCode length] > 0 && [iataCode rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
        return iataCode;
    }
    // Second choice: ICAO code
    else if ([icaoCode length] > 0) {
        return icaoCode;
    }
    // Third choice IATA code as-is
    else {
        return iataCode;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AirlineResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AirlineResultCell"];
    
    if (!cell) {
        cell = [[AirlineResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                 reuseIdentifier:@"AirlineResultCell"];
    }
    
    id tableRowObj = [self.airlines_ objectAtIndex:indexPath.row];
    
    if ([tableRowObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *airlineInfo = (NSDictionary *)tableRowObj;
        cell.airlineName = [airlineInfo valueForKeyOrNil:@"name"];
        cell.airlineCode = [self airlineCode:airlineInfo];
        cell.clearText = nil;
        cell.clearCell = NO;
    }
    else {
        cell.clearText = (NSString *)tableRowObj;
        cell.clearCell = YES;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < (NSInteger)[self.airlines_ count]) {
        id tableRowObj = [self.airlines_ objectAtIndex:indexPath.row];
        
        if ([tableRowObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *airlineInfo = [self.airlines_ objectAtIndex:indexPath.row];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSString *code = [self airlineCode:airlineInfo];
            [[JustLandedSession sharedSession] addToRecentlyLookedUpAirlines:airlineInfo];
            [self.delegate didChooseAirlineCode:code];
            [FlurryAnalytics logEvent:FY_CHOSE_AIRLINE];
        }
        else {
            [[JustLandedSession sharedSession] clearRecentlyLookedUpAirlines];
            self.airlines_ = [[JustLandedSession sharedSession] recentlyLookedUpAirlines];
            [self.resultsTable_ reloadData];
            [FlurryAnalytics logEvent:FY_CLEARED_RECENT];
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.airlines_ count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[[self.searchBar_ text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 && [self.airlines_ count] > 0) {
        return NSLocalizedString(@"Recent Airlines", @"Recent Airlines");
    }
    else {
        return nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Responding to Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)keyboardWasShown:(NSNotification *)notification {
    // Adjust the results table height
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.resultsTable_.frame = CGRectMake(0.0f, 44.0f, 320.0f, self.view.frame.size.height - self.searchBar_.frame.size.height - kbSize.height);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
