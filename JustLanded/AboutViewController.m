//
//  AboutViewController.m
//  JustLanded
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutTableViewCell.h"
#import "FAQViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
    AboutCellTagFeedback = 0,
    AboutCellTagTweet,
    AboutCellTagWebsite,
    AboutCellTagFAQ,
} AboutCellTag;


@interface AboutViewController ()

@property (strong, nonatomic) UITableView *aboutTable;

- (void)dismiss;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AboutViewController

@synthesize aboutTable;

- (id)init {
    self = [super init];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    [mainView setBackgroundColor:[UIColor grayColor]];
    self.view = mainView;
    
    // Add the table
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, AboutTableViewCellWidth, 6.0f * AboutTableViewCellHeight) 
                                                      style:UITableViewStyleGrouped];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setRowHeight:AboutTableViewCellHeight];
    [table setScrollEnabled:NO];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.aboutTable = table;
    [self.view addSubview:table];
    
    // Add the credits
    UILabel *creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 366.0f, 300.0f, 40.0f)];
    creditsLabel.backgroundColor = [UIColor clearColor];
    creditsLabel.textAlignment = UITextAlignmentCenter;
    creditsLabel.textColor = [UIColor blackColor];
    creditsLabel.font = [UIFont systemFontOfSize:14.0f];
    creditsLabel.numberOfLines = 2;
    creditsLabel.text = [NSString stringWithFormat:@"Designed in California by\nLittle Details LLC. Version %@",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [self.view addSubview:creditsLabel];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Set the title
    self.navigationItem.title = NSLocalizedString(@"About Just Landed", @"About Just Landed");
    
    // Add the done button to the navbar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                           target:self 
                                                                                           action:@selector(dismiss)];
    // Override back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:nil 
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.aboutTable = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Portrait only
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource & UITableViewDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (AboutCellTag)tagForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSMutableArray *tableRows = [[NSMutableArray alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        [tableRows addObject:[NSNumber numberWithInteger:AboutCellTagFeedback]];
    }
    if ([TWTweetComposeViewController canSendTweet]) {
        [tableRows addObject:[NSNumber numberWithInteger:AboutCellTagTweet]];
    }
    
    [tableRows addObject:[NSNumber numberWithInteger:AboutCellTagWebsite]];
    [tableRows addObject:[NSNumber numberWithInteger:AboutCellTagFAQ]];
    
    if (row < [tableRows count]) {
        return [[tableRows objectAtIndex:row] integerValue];
    }
    else {
        return [[tableRows lastObject] integerValue]; // Should never happen
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AboutTableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                         reuseIdentifier:@"AboutTableViewCell"];
    }
    
    AboutCellTag tag = [self tagForIndexPath:indexPath];
    cell.tag = tag;
    
    switch (tag) {
        case AboutCellTagFeedback: {
            cell.textLabel.text = NSLocalizedString(@"Send Us Feedback", @"Send Feedback");
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case AboutCellTagTweet: {
            cell.textLabel.text = NSLocalizedString(@"Tweet About Just Landed", @"Tweet About Us");
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case AboutCellTagWebsite: {
            cell.textLabel.text = NSLocalizedString(@"Just Landed Website", @"Just Landed Website");
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        default: {
            cell.textLabel.text = NSLocalizedString(@"Frequently Asked Questions", @"FAQ");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AboutCellTag tag = [self tagForIndexPath:indexPath];
    
    switch (tag) {
        case AboutCellTagFeedback: {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            [mailComposer setToRecipients:[NSArray arrayWithObject:@"feedback@getjustlanded.com"]];
            [mailComposer setSubject:[NSString stringWithFormat:@"Feedback on JustLanded v%@",
                                      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
            [mailComposer setMailComposeDelegate:self];
            mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:mailComposer animated:YES];
            break;
        }
        case AboutCellTagTweet: {
            TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
            [tweetComposer setInitialText:@"Never be late to pick someone up at the airport with the free @getjustlanded iPhone app. http://bit.ly/GCm511"];
            [tweetComposer setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                if (result == TWTweetComposeViewControllerResultDone) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"Thanks, we appreciate it!", @"Tweet Sent Thanks")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                                          otherButtonTitles:nil];
                    [alert show]; 
                }  
            }];
            [self presentModalViewController:tweetComposer animated:YES];
            break;
        }
        case AboutCellTagWebsite: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.getjustlanded.com"]];
            break;
        }
        default: {
            FAQViewController *faqVC = [[FAQViewController alloc] init];
            [self.navigationController pushViewController:faqVC animated:YES];
            break;
        }
    }
    
    // Deselect the cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numRows = 2;

    if ([TWTweetComposeViewController canSendTweet]) {
        numRows++;
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        numRows++;
    }

    return numRows;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MFMailComposeViewControllerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)mailComposeController:(MFMailComposeViewController *)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error {
    if (result == MFMailComposeResultSent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Feedback Sent!", @"Feedback Sent") 
                                                        message:NSLocalizedString(@"We read every piece of feedback and appreciate your suggestions.", @"Feedback Sent Thanks")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
