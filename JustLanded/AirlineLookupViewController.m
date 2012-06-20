//
//  AirlineLookupViewController.m
//  JustLanded
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "AirlineLookupViewController.h"
#import "AirlineResultTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface AirlineLookupViewController () {
    __strong NSArray *_allAirlines;
    __strong NSArray *_airlines;
    __strong JLLabel *_noResultsLabel;
    __strong UISearchBar *_searchBar;
    __strong UITableView *_resultsTable;
}

- (void)keyboardWasShown:(NSNotification *)notification;

@end

@implementation AirlineLookupViewController

@synthesize delegate;


- (id)init {
    self = [super init];
    
    if (self) {
        _allAirlines = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"airlines" ofType:@"plist"]];
        _airlines = [[JustLandedSession sharedSession] recentlyLookedUpAirlines];
        
        if ([_airlines count] > 0) {
            NSMutableArray *airlinesWithClear = [[NSMutableArray alloc] initWithArray:_airlines];
            [airlinesWithClear addObject:@"Clear Recent"];
            _airlines = airlinesWithClear;
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
    
    _searchBar = searchBar;
    [self.view addSubview:_searchBar];
    
    _resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, self.view.frame.size.height - _searchBar.frame.size.height) 
                                                 style:UITableViewStylePlain];
    _resultsTable.delegate = self;
    _resultsTable.dataSource = self;
    _resultsTable.rowHeight = AirlineResultCellHeight;
    _resultsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _resultsTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:_resultsTable];
    
    _noResultsLabel = [[JLLabel alloc] initWithLabelStyle:[JLLookupStyles noAirlineResultsLabel] frame:AIRLINE_NO_RESULTS_LABEL_FRAME];
    _noResultsLabel.text = NSLocalizedString(@"No Matching Airlines :(", @"No Matching Airlines");
    [_resultsTable addSubview:_noResultsLabel];
    _noResultsLabel.hidden = YES;
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
                                                                             target:delegate
                                                                             action:@selector(cancelledAirlineLookup)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWasShown:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
    
    [_searchBar becomeFirstResponder];
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
        _airlines = [_allAirlines mutableCopy];
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *searchTerm = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *searchTermNoSpaces = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([searchTerm length] > 0) {
        NSMutableArray *matchingAirlines = [[NSMutableArray alloc] init];
        
        for (NSDictionary *airline in _airlines) {
            NSString *airlineNameNoSpaces = [[airline objectForKeyOrNil:@"name"] stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if ([airlineNameNoSpaces rangeOfString:searchTermNoSpaces options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSAnchoredSearch)].location != NSNotFound) {
                [matchingAirlines addObject:airline];
            }
        }
        
        _airlines = matchingAirlines;
    }
    else {
        _airlines = [[JustLandedSession sharedSession] recentlyLookedUpAirlines];
        
        if ([_airlines count] > 0) {
            NSMutableArray *airlinesWithClear = [[NSMutableArray alloc] initWithArray:_airlines];
            [airlinesWithClear addObject:@"Clear Recent"];
            _airlines = airlinesWithClear;
        }
    }
    
    if ([_airlines count] == 0 && [searchTerm length] > 0) {
        _noResultsLabel.hidden = NO;
    }
    else {
        _noResultsLabel.hidden = YES;
    }
        
    [_resultsTable reloadData];
    [_resultsTable setContentOffset:CGPointZero animated:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate & DataSource Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AirlineResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AirlineResultCell"];
    
    if (!cell) {
        cell = [[AirlineResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                 reuseIdentifier:@"AirlineResultCell"];
    }
    
    id tableRowObj = [_airlines objectAtIndex:indexPath.row];
    
    if ([tableRowObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *airlineInfo = (NSDictionary *)tableRowObj;
        cell.airlineName = [airlineInfo valueForKeyOrNil:@"name"];
        NSString *iataCode = [airlineInfo valueForKeyOrNil:@"iata"];
        NSString *icaoCode = [airlineInfo valueForKeyOrNil:@"icao"];
        cell.code = icaoCode != nil && [icaoCode length] > 0? icaoCode : iataCode;
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
    if (indexPath.row < [_airlines count]) {
        id tableRowObj = [_airlines objectAtIndex:indexPath.row];
        
        if ([tableRowObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *airlineInfo = [_airlines objectAtIndex:indexPath.row];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSString *iataCode = [airlineInfo valueForKeyOrNil:@"iata"];
            NSString *icaoCode = [airlineInfo valueForKeyOrNil:@"icao"];
            NSString *code = icaoCode != nil && [icaoCode length] > 0 ? icaoCode : iataCode;
            [[JustLandedSession sharedSession] addToRecentlyLookedUpAirlines:airlineInfo];
            [self.delegate didChooseAirlineCode:code];
            [FlurryAnalytics logEvent:FY_CHOSE_AIRLINE];
        }
        else {
            [[JustLandedSession sharedSession] clearRecentlyLookedUpAirlines];
            _airlines = [[JustLandedSession sharedSession] recentlyLookedUpAirlines];
            [_resultsTable reloadData];
            [FlurryAnalytics logEvent:FY_CLEARED_RECENT];
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_airlines count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[[_searchBar text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 && [_airlines count] > 0) {
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
    
    _resultsTable.frame = CGRectMake(0.0f, 44.0f, 320.0f, self.view.frame.size.height - _searchBar.frame.size.height - kbSize.height);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
