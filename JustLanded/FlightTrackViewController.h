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
- (void)didFinishTracking:(FlightTrackViewController *)controller userInitiated:(BOOL)flag;
@end


@interface FlightTrackViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <FlightTrackViewControllerDelegate> delegate;
@property (readonly, nonatomic) Flight *trackedFlight;

- (id)initWithFlight:(Flight *)aFlight;
- (void)stopTracking;
- (void)refresh;

@end
