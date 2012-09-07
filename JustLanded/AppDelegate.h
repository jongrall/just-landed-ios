//
//  AppDelegate.h
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const DidUpdatePushTokenNotification;
extern NSString * const DidFailToUpdatePushTokenNotification;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, readonly, copy) NSString *pushToken;
@property (nonatomic, readonly) BOOL triedToRegisterForRemoteNotifications;
@property (atomic) UIBackgroundTaskIdentifier wakeupTrackTask;

- (void)startMonitoringMovementFromLocation:(CLLocation *)loc;
- (void)stopMonitoringMovement;

@end
