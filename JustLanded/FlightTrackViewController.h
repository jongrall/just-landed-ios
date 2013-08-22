//
//  FlightTrackViewController.h
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLViewController.h"

@class FlightTrackViewController;
@class Flight;

@protocol FlightTrackViewControllerDelegate
- (void)didFinishTrackingFlight:(Flight *)aFlight userInitiated:(BOOL)userFlag;
@end


@interface FlightTrackViewController : JLViewController

@property (weak, nonatomic) id <FlightTrackViewControllerDelegate> trackDelegate;

- (id)initWithFlight:(Flight *)aFlight;
- (void)track;

@end
