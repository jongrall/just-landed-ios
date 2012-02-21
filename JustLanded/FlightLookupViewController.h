//
//  FlightLookupViewController.h
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "FlightTrackViewController.h"
#import "Flight.h"

@interface FlightLookupViewController : UIViewController <FlightTrackViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

- (void)beginTrackingFlight:(Flight *)aFlight animated:(BOOL)animateFlip;

@end
