//
//  FlightLookupViewController.h
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "FlightTrackViewController.h"
#import "AirlineLookupViewController.h"
#import "Flight.h"

@interface FlightLookupViewController : UIViewController <FlightTrackViewControllerDelegate, AirlineLookupDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, readonly) UITextField *flightNumberField;

- (void)beginTrackingFlight:(Flight *)aFlight animated:(BOOL)animateFlip;

@end
