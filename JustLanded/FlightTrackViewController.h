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
- (void)didFinishTracking:(FlightTrackViewController *)controller userInitiated:(BOOL)user_flag;
@end


@interface FlightTrackViewController : UIViewController <NoConnectionDelegate>

@property (weak, nonatomic) id <FlightTrackViewControllerDelegate> delegate;
@property (readonly, nonatomic) Flight *trackedFlight;

- (id)initWithFlight:(Flight *)aFlight;
- (void)refresh;

@end
