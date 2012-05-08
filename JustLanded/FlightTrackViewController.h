//
//  FlightTrackViewController.h
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightTrackViewController;
@class Flight;

@protocol FlightTrackViewControllerDelegate
- (void)didFinishTrackingUserInitiated:(BOOL)user_flag;
@end


@interface FlightTrackViewController : UIViewController

@property (weak, nonatomic) id <FlightTrackViewControllerDelegate> delegate;
@property (readonly, nonatomic) Flight *trackedFlight;

- (id)initWithFlight:(Flight *)aFlight;
- (void)refresh;

@end
