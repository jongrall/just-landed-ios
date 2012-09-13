//
//  AppDelegate.h
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const DidUpdatePushTokenNotification;
extern NSString * const DidFailToUpdatePushTokenNotification;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, readonly, nonatomic) NSString *pushToken;
@property (readonly, nonatomic) BOOL triedToRegisterForRemoteNotifications;
@property (nonatomic) BOOL respondedToTextOnArrivalNotification;
@property (atomic) UIBackgroundTaskIdentifier wakeupTrackTask;

- (void)startMonitoringMovementFromLocation:(CLLocation *)aLocation;
- (void)stopMonitoringMovement;

@end
