//
//  FlightTrackViewController.h
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightTrackViewController;
@class Flight;

@protocol FlightTrackViewControllerDelegate
- (void)didFinishTrackingFlight:(Flight *)aFlight userInitiated:(BOOL)userFlag;
@end


@interface FlightTrackViewController : UIViewController

@property (weak, nonatomic) id <FlightTrackViewControllerDelegate> delegate;

- (id)initWithFlight:(Flight *)aFlight;

@end
