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
#import "JLMailComposeViewController.h"
#import <QuartzCore/QuartzCore.h>

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
- (BOOL)setMFMailFieldAsFirstResponder:(UIView *)view mfMailField:(NSString *)field;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AboutViewController

@synthesize aboutTable;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)loadView {    
    UIImageView *mainView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"about_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0f, 9.0f, 9.0f, 9.0f)]];
    mainView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 416.0f);
    mainView.userInteractionEnabled = YES;
    self.view = mainView;
    
    // Add the table
    UITableView *table = [[UITableView alloc] initWithFrame:TABLE_FRAME 
                                                      style:UITableViewStyleGrouped];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setRowHeight:AboutTableViewCellHeight];
    [table setScrollEnabled:NO];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.aboutTable = table;
    [self.view addSubview:table];
    
    // Add the credits
    JLLabel *companyLabel = [[JLLabel alloc] initWithLabelStyle:[JLAboutStyles companyLabelStyle] frame:COMPANY_NAME_FRAME];
    companyLabel.text = NSLocalizedString(@"Little Details LLC", @"Little Details LLC");
    
    UIImageView *divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
    divider.frame = DIVIDER_FRAME;
    
    JLLabel *versionLabel = [[JLLabel alloc] initWithLabelStyle:[JLAboutStyles versionLabelStyle] frame:VERSION_FRAME];
    versionLabel.text = [NSString stringWithFormat:@"Version %@",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    [self.view addSubview:companyLabel];
    [self.view addSubview:divider];
    [self.view addSubview:versionLabel];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Custom navbar shadow
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
	self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5f;
	self.navigationController.navigationBar.layer.shadowRadius = 0.25f;
	self.navigationController.navigationBar.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self.navigationController.navigationBar bounds]] CGPath]; //Optimization avoids offscreen render pass

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") 
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self 
                                                                             action:@selector(dismiss)];
	
    // Set the title
    self.navigationItem.title = NSLocalizedString(@"About", @"About");
    
    
    // Override back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil 
                                                                            action:nil];
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


- (void)dealloc {
    aboutTable.delegate = nil;
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
    AboutTableViewCell *cell = (AboutTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AboutTableViewCell"];
    
    if (!cell) {
        cell = [[AboutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                         reuseIdentifier:@"AboutTableViewCell"];
        cell.backgroundView.opaque = NO;
        cell.selectedBackgroundView.opaque = NO;
    }
    
    AboutCellTag tag = [self tagForIndexPath:indexPath];
    cell.tag = tag;
    
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
    
    switch (tag) {
        case AboutCellTagFeedback: {
            cell.title = NSLocalizedString(@"Send us feedback", @"Send Feedback");
            cell.icon = [UIImage imageNamed:@"email_feedback" 
                                  withColor:[UIColor whiteColor] 
                                shadowColor:[UIColor colorWithRed:16.0f/255.0f green:82.0f/255.0f blue:113.0f/255.0f alpha:1.0f]
                               shadowOffset:CGSizeMake(0.0f, -0.5f) 
                                 shadowBlur:0.0f];
            cell.hasDisclosureArrow = NO;
            break;
        }
        case AboutCellTagTweet: {
            cell.title = NSLocalizedString(@"Tell your followers", @"Tweet About Us");
            cell.icon = [UIImage imageNamed:@"twitter" 
                                  withColor:[UIColor whiteColor] 
                                shadowColor:[UIColor colorWithRed:16.0f/255.0f green:82.0f/255.0f blue:113.0f/255.0f alpha:1.0f]
                               shadowOffset:CGSizeMake(0.0f, -0.5f) 
                                 shadowBlur:0.0f];
            cell.hasDisclosureArrow = NO;
            break;
        }
        case AboutCellTagWebsite: {
            cell.title = NSLocalizedString(@"Visit the website", @"Just Landed Website");
            cell.icon = [UIImage imageNamed:@"visit_site" 
                                  withColor:[UIColor whiteColor] 
                                shadowColor:[UIColor colorWithRed:16.0f/255.0f green:82.0f/255.0f blue:113.0f/255.0f alpha:1.0f]
                               shadowOffset:CGSizeMake(0.0f, -0.5f) 
                                 shadowBlur:0.0f];
            cell.hasDisclosureArrow = NO;
            break;
        }
        default: {
            cell.title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
            cell.icon = [UIImage imageNamed:@"faq" 
                                  withColor:[UIColor whiteColor] 
                                shadowColor:[UIColor colorWithRed:16.0f/255.0f green:82.0f/255.0f blue:113.0f/255.0f alpha:1.0f]
                               shadowOffset:CGSizeMake(0.0f, -0.5f) 
                                 shadowBlur:0.0f];
            cell.hasDisclosureArrow = YES;
            break;
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AboutCellTag tag = [self tagForIndexPath:indexPath];
    
    switch (tag) {
        case AboutCellTagFeedback: {
            JLMailComposeViewController *mailComposer = [[JLMailComposeViewController alloc] init];
            [mailComposer setToRecipients:[NSArray arrayWithObject:@"feedback@getjustlanded.com"]];
            [mailComposer setSubject:[NSString stringWithFormat:@"Feedback on JustLanded v%@",
                                      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
            [mailComposer setMailComposeDelegate:self];
            mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            mailComposer.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
            mailComposer.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
            mailComposer.navigationBar.layer.shadowOpacity = 0.5f;
            mailComposer.navigationBar.layer.shadowRadius = 0.25f;
            mailComposer.navigationBar.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self.navigationController.navigationBar bounds]] CGPath]; //Optimization avoids offscreen render pass
            
            [self presentModalViewController:mailComposer animated:YES];
            
            // WARN: Make the body first responder - this could get us rejected
            [self setMFMailFieldAsFirstResponder:mailComposer.view mfMailField:@"MFComposeTextContentView"];
            
            [FlurryAnalytics logEvent:FY_STARTED_SENDING_FEEDBACK];
            break;
        }
        case AboutCellTagTweet: {
            TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
            NSArray *possibleTweets = [NSArray arrayWithObjects:@"The free Just Landed iPhone app makes it easy to pick people up at the airport on time! http://bit.ly/GCm511",
                                       @"The free Just Landed iPhone app makes it easy to pick people up at the airport! http://bit.ly/GCm511",
                                       @"Just Landed for iPhone makes it easy to pick people up at the airport! http://bit.ly/GCm511",
                                       @"Problem solved: never be late to pick someone up at the airport again! http://bit.ly/GCm511",
                                       @"Just Landed is a new kind of flight tracker that tells you when to leave for the airport! http://bit.ly/GCm511", nil];
            
            // Choose a random tweet for some variety
            NSUInteger randomIndex = arc4random() % [possibleTweets count];
            [tweetComposer setInitialText:[possibleTweets objectAtIndex:randomIndex]];
            [tweetComposer setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                if (result == TWTweetComposeViewControllerResultDone) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"Thanks, we appreciate it!", @"Tweet Sent Thanks")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                                          otherButtonTitles:nil];
                    [alert show];
                    [FlurryAnalytics logEvent:FY_POSTED_TWEET];
                }
                else {
                    [FlurryAnalytics logEvent:FY_ABANDONED_TWEETING];
                }
            }];
            [self presentModalViewController:tweetComposer animated:YES];
            [FlurryAnalytics logEvent:FY_STARTED_TWEETING];
            break;
        }
        case AboutCellTagWebsite: {
            [FlurryAnalytics logEvent:FY_VISITED_WEBSITE];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.getjustlanded.com"]];
            break;
        }
        default: {
            FAQViewController *faqVC = [[FAQViewController alloc] init];
            [self.navigationController pushViewController:faqVC animated:YES];
            [FlurryAnalytics logEvent:FY_READ_FAQ];
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
        [FlurryAnalytics logEvent:FY_SENT_FEEDBACK];
    }
    else if (result == MFMailComposeResultCancelled) {
        [FlurryAnalytics logEvent:FY_ABANDONED_SENDING_FEEDBACK];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

//Returns true if the ToAddress field was found any of the sub views and made first responder
//passing in @"MFComposeSubjectView"     as the value for field makes the subject become first responder 
//passing in @"MFComposeTextContentView" as the value for field makes the body become first responder 
//passing in @"RecipientTextField"       as the value for field makes the to address field become first responder 
- (BOOL)setMFMailFieldAsFirstResponder:(UIView *)view mfMailField:(NSString *)field {
    for (UIView *subview in view.subviews) {
        
        NSString *className = [NSString stringWithFormat:@"%@", [subview class]];
        if ([className isEqualToString:field]) {
            //Found the sub view we need to set as first responder
            [subview becomeFirstResponder];
            return YES;
        }
        
        if ([subview.subviews count] > 0) {
            if ([self setMFMailFieldAsFirstResponder:subview mfMailField:field]){
                //Field was found and made first responder in a subview
                return YES;
            }
        }
    }
    
    //field not found in this view.
    return NO;
}

@end
