//
//  AboutViewController.m
//  Just Landed
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutTableViewCell.h"
#import "WebContentViewController.h"
#import "JLMailComposeViewController.h"
#import "JLMessageComposeViewController.h"
#import <Twitter/TWTweetComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
    AboutCellTagFeedback = 0,
    AboutCellTagFAQ,
    AboutCellTagSMS,
    AboutCellTagTweet,
    AboutCellTagTerms,
} AboutCellTag;


@interface AboutViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) JLButton *aboutButton_;
@property (strong, nonatomic) JLLabel *aboutTitle_;
@property (strong, nonatomic) UITableView *aboutTable_;
@property (strong, nonatomic) UIImageView *cloudFooter_;
@property (strong, nonatomic) JLLabel *copyrightLabel_;

- (void)dismiss;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AboutViewController

@synthesize airplane = airplane_;
@synthesize aboutTable_;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {    
    UIImageView *mainView = [[UIImageView alloc] initWithFrame:CGRectZero];
    mainView.image = [UIImage imageNamed:[@"sky_bg" imageName]];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    mainView.frame = CGRectMake(0.0f,
                                0.0f,
                                screenBounds.size.width,
                                screenBounds.size.height - 20.0f); // Status bar
    mainView.userInteractionEnabled = YES;
    self.view = mainView;
    
    // Add the about button
    self.aboutButton_ = [[JLButton alloc] initWithButtonStyle:[JLAboutStyles aboutCloseButtonStyle]
                                                        frame:[JLLookupStyles aboutButtonFrame]]; // Frame matches lookup
    [self.aboutButton_ addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.aboutButton_.enabled = NO;
    [self.view addSubview:self.aboutButton_];
    
    // Add the title
    self.aboutTitle_ = [[JLLabel alloc] initWithLabelStyle:[JLAboutStyles aboutTitleLabelStyle]
                                                     frame:[JLAboutStyles aboutTitleFrame]];
    self.aboutTitle_.text = NSLocalizedString(@"about", @"About Screen Title");
    self.aboutTitle_.hidden = YES; // Hidden at first
    [self.view addSubview:self.aboutTitle_];
    
    // Add the cloud layer
    self.cloudLayer = [[JLCloudLayer alloc] initWithFrame:[JLLookupStyles cloudLayerFrame]]; // Frame matches lookup
    self.cloudLayer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.cloudLayer];
    
    // Add the cloud foreground
    self.cloudFooter_ = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"lookup_cloud_fg"]
                                                            resizableImageWithCapInsets:UIEdgeInsetsMake(9.0f, 9.0f, 9.0f, 9.0f)]];
    self.cloudFooter_.frame = [JLLookupStyles cloudFooterFrame]; // Frame matches lookup
    self.cloudFooter_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.cloudFooter_];
    
    // Add the table
    UITableView *table = [[UITableView alloc] initWithFrame:[JLAboutStyles tableFrame]
                                                      style:UITableViewStylePlain];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setScrollEnabled:NO];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [table setHidden:YES]; // Hidden at first
    [table setRowHeight:AboutTableViewCellHeight];
    self.aboutTable_ = table;
    [self.view addSubview:table];
    
    // Add the credits
    self.copyrightLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLAboutStyles copyrightLabelStyle]
                                                         frame:[JLAboutStyles copyrightNoticeFrame]];
    self.copyrightLabel_.text = [NSString stringWithFormat:NSLocalizedString(@"©2012 Little Details LLC. Just Landed %@", @"Copyright Notice"),
                                 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    self.copyrightLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.copyrightLabel_.hidden = YES; // Hidden at first
    
    [self.view addSubview:self.copyrightLabel_];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start animating the clouds
    [self.cloudLayer startAnimating];
    
    // Override back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil 
                                                                            action:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view
    self.cloudLayer = nil;
    self.airplane = nil;
    self.aboutButton_ = nil;
    self.cloudFooter_ = nil;
    self.aboutTitle_ = nil;
    self.aboutTable_ = nil;
    self.copyrightLabel_ = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    if (!self.presentedViewController) { // Don't show the navbar again for modal view controllers covering
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Portrait only
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)revealContent {
    // Animate the clouds out of the way, and the table into view
    [UIView animateWithDuration:CLOUD_REVEAL_ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cloudLayer.frame = [JLAboutStyles cloudLayerLowerFrame];
                         self.cloudFooter_.frame = [JLAboutStyles cloudFooterLowerFrame];
                         self.airplane.frame = [JLAboutStyles airplaneLowerFrame];
                     }
                     completion:^(BOOL finished) {
                         self.aboutTitle_.alpha = 0.0f;
                         self.aboutTitle_.hidden = NO;
                         self.aboutTable_.alpha = 0.0f;
                         self.aboutTable_.hidden = NO;
                         self.copyrightLabel_.alpha = 0.0f;
                         self.copyrightLabel_.hidden = NO;
                         
                         [UIView animateWithDuration:FADE_ANIMATION_DURATION
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.aboutTitle_.alpha = 1.0f;
                                              self.aboutTable_.alpha = 1.0f;
                                              self.copyrightLabel_.alpha = 1.0f;
                                          }
                                          completion:^(BOOL finishedAlso) {
                                              self.aboutButton_.enabled = YES;
                                          }];
                     }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setAirplane:(JLAirplaneView *)anAirplane {
    if (airplane_ != anAirplane) {
        airplane_ = anAirplane;
    
        // Side effect - adds the plane to the view
        [[self view] insertSubview:airplane_ belowSubview:self.aboutTable_];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dismiss {
    // Fade the table, and the clouds back into view, then dismiss the about screen
    self.aboutButton_.enabled = NO;
    [UIView animateWithDuration:FADE_ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.aboutTitle_.alpha = 0.0f;
                         self.aboutTable_.alpha = 0.0f;
                         self.copyrightLabel_.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:CLOUD_REVEAL_ANIMATION_DURATION
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.cloudLayer.frame = [JLLookupStyles cloudLayerFrame];
                                              self.cloudFooter_.frame = [JLLookupStyles cloudFooterFrame];
                                              self.airplane.frame = [JLLookupStyles airplaneFrame];
                                          }
                                          completion:^(BOOL finishedAlso) {
                                              [[self.presentingViewController view] addSubview:self.airplane]; // Give the airplane back :)
                                              [self dismissViewControllerAnimated:NO completion:NULL]; // Instant transition
                                          }];
                     }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource & UITableViewDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (AboutCellTag)tagForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSMutableArray *tableRows = [[NSMutableArray alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        [tableRows addObject:@(AboutCellTagFeedback)];
    }
    
    [tableRows addObject:@(AboutCellTagFAQ)];
    
    if ([MFMessageComposeViewController canSendText]) {
        [tableRows addObject:@(AboutCellTagSMS)];
    }
    if ([TWTweetComposeViewController canSendTweet]) {
        [tableRows addObject:@(AboutCellTagTweet)];
    }

    [tableRows addObject:@(AboutCellTagTerms)];
    
    if (row < [tableRows count]) {
        return [tableRows[row] integerValue];
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
            cell.icon = [UIImage imageNamed:@"email_feedback_up"];
            cell.downIcon = [UIImage imageNamed:@"email_feedback_down"];
            cell.hasDisclosureArrow = NO;
            break;
        }
        case AboutCellTagSMS: {
            cell.title = NSLocalizedString(@"Text a friend", @"Text a Friend About Just Landed");
            cell.icon = [UIImage imageNamed:@"text_up"];
            cell.downIcon = [UIImage imageNamed:@"text_down"];
            cell.hasDisclosureArrow = NO;
            break;
        }
        case AboutCellTagTweet: {
            cell.title = NSLocalizedString(@"Tell your followers", @"Tweet About Us");
            cell.icon = [UIImage imageNamed:@"twitter_up"];
            cell.downIcon = [UIImage imageNamed:@"twitter_down"];
            cell.hasDisclosureArrow = NO;
            break;
        }
        case AboutCellTagFAQ: {
            cell.title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");
            cell.icon = [UIImage imageNamed:@"faq_up"];
            cell.downIcon = [UIImage imageNamed:@"faq_down"];
            cell.hasDisclosureArrow = YES;
            break;
        }
        default: {
            cell.title = NSLocalizedString(@"Terms of service", @"Terms of service");
            cell.icon = [UIImage imageNamed:@"terms_up"];
            cell.downIcon = [UIImage imageNamed:@"terms_down"];
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
            [mailComposer setToRecipients:@[@"feedback@getjustlanded.com"]];
            [mailComposer setSubject:[NSString stringWithFormat:@"Feedback on JustLanded v%@",
                                      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
            [mailComposer setMailComposeDelegate:self];
            mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:mailComposer animated:YES completion:NULL];
            
            // WARN: Make the body first responder - this could get us rejected
            [mailComposer setMFMailFieldAsFirstResponder];
            
            [Flurry logEvent:FY_STARTED_SENDING_FEEDBACK];
            break;
        }
        case AboutCellTagSMS: {
            JLMessageComposeViewController *smsComposer = [[JLMessageComposeViewController alloc] init];
            [smsComposer setMessageComposeDelegate:self];
            
            NSArray *possibleMessages = @[@"Check out the Just Landed iPhone app - it makes it easy to pick people up at the airport. http://bit.ly/QkAJfu",
                                       @"No more waiting at airport arrivals with Just Landed for iPhone! http://bit.ly/SirUWY",
                                       @"I'm loving the Just Landed iPhone app. It tells you when to leave for the airport to pick someone up! http://bit.ly/NbLqkJ",
                                       @"Problem solved: never be late to pick someone up at the airport again! http://bit.ly/TkBoi2",
                                       @"I've found an iPhone app called Just Landed that is great for tracking arriving flights! http://bit.ly/QkAYqH"];
            NSUInteger randomIndex = arc4random() % [possibleMessages count];
            [smsComposer setBody:possibleMessages[randomIndex]];
            smsComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:smsComposer animated:YES completion:NULL];
            // Hack to fix MFMMessageCompose changing status bar type
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            [Flurry logEvent:FY_STARTED_SENDING_SMS];
            break;
        }
        case AboutCellTagTweet: {
            TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
            NSArray *possibleTweets = @[@"The @justlanded iPhone app makes it easy to pick people up at the airport on time! http://bit.ly/PHaLQP",
                                       @"No more waiting at airport arrivals with @justlanded for iPhone! http://bit.ly/Q4A6mJ",
                                       @"The @justlanded iPhone app tells you when to leave for the airport to pick someone up! http://bit.ly/Ol9RsY",
                                       @"Problem solved: never be late to pick someone up at the airport again! http://bit.ly/TWHHpE",
                                       @"The @justlanded iPhone app is great for tracking arriving flights. http://bit.ly/TksJw3"];
            
            // Choose a random tweet for some variety
            NSUInteger randomIndex = arc4random() % [possibleTweets count];
            [tweetComposer setInitialText:possibleTweets[randomIndex]];
            [tweetComposer setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Always perform this on the main thread
                    if (result == TWTweetComposeViewControllerResultDone) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:NSLocalizedString(@"Thanks, we appreciate it!", @"Tweet Sent Thanks")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                                              otherButtonTitles:nil];
                        [alert show];
                        [Flurry logEvent:FY_POSTED_TWEET];
                    }
                    else {
                        [Flurry logEvent:FY_ABANDONED_TWEETING];
                    }
                    
                    [self dismissViewControllerAnimated:NO completion:NULL];
                });
            }];
            [self presentViewController:tweetComposer animated:YES completion:NULL];
            [Flurry logEvent:FY_STARTED_TWEETING];
            break;
        }
        case AboutCellTagTerms: {
            WebContentViewController *tosVC = [[WebContentViewController alloc] initWithContentTitle:NSLocalizedString(@"Terms of Service", @"Terms of Service.")
                                                                                                 URL:[NSURL URLWithString:[WEB_HOST stringByAppendingString:TOS_PATH]]
                                                                                      showDoneButton:NO];
            [self.navigationController pushViewController:tosVC animated:YES];
            [Flurry logEvent:FY_READ_TERMS];
            break;
        }
        case AboutCellTagFAQ: {
            WebContentViewController *faqVC = [[WebContentViewController alloc] initWithContentTitle:NSLocalizedString(@"F.A.Q.", @"F.A.Q.")
                                                                                                 URL:[NSURL URLWithString:[WEB_HOST stringByAppendingString:FAQ_PATH]]
                                                                                      showDoneButton:NO];
            [self.navigationController pushViewController:faqVC animated:YES];
            [Flurry logEvent:FY_READ_FAQ];
            break;
        }
        default: {
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
    
    if ([MFMailComposeViewController canSendMail]) {
        numRows++;
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        numRows++;
    }

    if ([TWTweetComposeViewController canSendTweet]) {
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
        [Flurry logEvent:FY_SENT_FEEDBACK];
    }
    else if (result == MFMailComposeResultCancelled) {
        [Flurry logEvent:FY_ABANDONED_SENDING_FEEDBACK];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MFMessageComposeViewControllerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Thanks, we appreciate you telling your friends!", @"SMS Sent Thanks")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        [Flurry logEvent:FY_SENT_SMS];
    }
    else if (result == MessageComposeResultCancelled) {
        [Flurry logEvent:FY_ABANDONED_SENDING_SMS];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    aboutTable_.delegate = nil;
}

@end
