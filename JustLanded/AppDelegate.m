//
//  AppDelegate.m
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "AppDelegate.h"

#import "FlightLookupViewController.h"
#import "Flight.h"
#import <CoreLocation/CoreLocation.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface AppDelegate ()

- (void)didTrackFlight:(NSNotification *)notification;
- (void)didUntrackFlight:(NSNotification *)notification;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FlurryAnalytics startSession:FLURRY_APPLICATION_KEY];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Show the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Register for push notifications
    [[JustLandedSession sharedSession] registerForPushNotifications];
    
    // Listen for tracking and untracking of any flights so we can set and unset leave alerts
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didTrackFlight:)
                                                 name:DidTrackFlightNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUntrackFlight:)
                                                 name:DidStopTrackingFlightNotification 
                                               object:nil];
    
    // Show the flight lookup UI    
    self.mainViewController = [[FlightLookupViewController alloc] init];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    // Show previous flights being tracked, if any
    NSArray *prevFlights = [[JustLandedSession sharedSession] currentlyTrackedFlights];
    
    if ([prevFlights count] > 0) {
        // Display the most recently tracked flight
        [self.mainViewController beginTrackingFlight:[prevFlights lastObject] animated:NO];
    }
    else {
        [self.mainViewController.flightNumberField becomeFirstResponder];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Responding to NSNotificationCenter Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)didTrackFlight:(NSNotification *)notification {
    Flight *aFlight = [notification object];
    [aFlight createOrUpdateLeaveAlerts];
}


- (void)didUntrackFlight:(NSNotification *)notification {
    Flight *aFlight = [notification object];
    [aFlight cancelLeaveAlerts];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push & Local Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //Keep the server up to date with the latest push token
	[[JustLandedSession sharedSession] updatePushTokenAfterRegisteringWithApple:[deviceToken hexString]];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[JustLandedSession sharedSession] didFailToRegisterForRemoteNotifications:error];
    NSLog(@"Just Landed failed to register for remote notifications: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // TODO: Implement me
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {    
    // App is currently running - display an alert and sound
    for (Flight *f in [[JustLandedSession sharedSession] currentlyTrackedFlights]) {
        if ([f matchesAlert:notification]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:notification.alertBody 
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                                  otherButtonTitles:nil];
            [alert show];
            [[JustLandedSession sharedSession] playSound:AnnouncementSound];
            [[JustLandedSession sharedSession] vibrateDevice];
            break;
        }
    }
}

@end
