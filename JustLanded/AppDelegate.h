//
//  AppDelegate.h
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWQuincyManager.h"
#import "BWHockeyManager.h"

extern NSString * const DidUpdatePushTokenNotification;
extern NSString * const DidFailToUpdatePushTokenNotification;

@class FlightLookupViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, copy, nonatomic) NSString *pushToken;
@property (readonly, nonatomic) BOOL triedToRegisterForRemoteNotifications;
@property (nonatomic) UIBackgroundTaskIdentifier wakeupTrackTask;

- (void)startMonitoringMovementFromLocation:(CLLocation *)loc;
- (void)stopMonitoringMovement;

@end
