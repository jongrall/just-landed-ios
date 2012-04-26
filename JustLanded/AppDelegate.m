//
//  AppDelegate.m
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "AppDelegate.h"

#import "FlightLookupViewController.h"
#import "FlightTrackViewController.h"
#import "Flight.h"
#import <CoreLocation/CoreLocation.h>


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Show the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Configure Flurry
    [FlurryAnalytics startSession:FLURRY_APPLICATION_KEY];
    [FlurryAnalytics setSessionReportsOnPauseEnabled:YES];
    [FlurryAnalytics setSecureTransportEnabled:YES];
    
    // App distribution
    #ifdef CONFIGURATION_Adhoc
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:HOCKEY_APP_ID];
    [[BWHockeyManager sharedHockeyManager] setAlwaysShowUpdateReminder:YES];
    [[BWHockeyManager sharedHockeyManager] setDelegate:self];
    #endif
    
    // Crash reporting
    #ifndef CONFIGURATION_Debug
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:HOCKEY_APP_ID];
    [[BWQuincyManager sharedQuincyManager] setAutoSubmitCrashReport:YES];
    [[BWQuincyManager sharedQuincyManager] setDelegate:self];
    #endif
        
    // Register for push notifications
    [[JustLandedSession sharedSession] registerForPushNotifications];
    
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
#pragma mark - Custom Device Identifier Required by BWHockerManagerDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)customDeviceIdentifier {
    #ifdef CONFIGURATION_Adhoc
    return [[JustLandedSession sharedSession] UUID];
    #endif
    
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Crash Log
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSString *)crashReportUserID {
    return [[JustLandedSession sharedSession] UUID];
}


- (NSString *)crashReportDescription {
    if ([[[JustLandedSession sharedSession] currentlyTrackedFlights] count] == 0) {
        return @"User was not tracking any flights at the time of the crash.";
    }
    else {
        NSString *message_start = @"The user was tracking flights when the app crashed.";
        NSMutableArray *flightData = [[NSMutableArray alloc] init];
        
        for (Flight *f in [[JustLandedSession sharedSession] currentlyTrackedFlights]) {
            [flightData addObject:[f flightDataAsJson]];
        }
        
        return [NSString stringWithFormat:@"%@\n\n%@", message_start,
                [flightData componentsJoinedByString:@"\n\n"]];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[JustLandedSession sharedSession] updatePushTokenAfterRegisteringWithApple:[deviceToken hexString]];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[JustLandedSession sharedSession] didFailToRegisterForRemoteNotifications:error];
    NSLog(@"Just Landed failed to register for remote notifications: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Only alert them if they haven't been told yet and they are still tracking flights.
    // (UIApplicationStateInactive indicates the app was launched in
    // response to the user tapping the action button of the push notification).
    NSArray *currentlyTrackedFlights = [[JustLandedSession sharedSession] currentlyTrackedFlights];
    BOOL isTrackingFlights = [currentlyTrackedFlights count] > 0;
    BOOL notAlreadyNotified = [[UIApplication sharedApplication] applicationState] != UIApplicationStateInactive;
    
    if (isTrackingFlights && notAlreadyNotified) {
        // Only do something if they are still tracking a flight
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.alertBody = [userInfo valueForKeyPathOrNil:@"aps.alert"];;
        notification.soundName = [userInfo valueForKeyPathOrNil:@"aps.sound"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
             
        // Refresh the flight information
        Flight *currentFlight = [currentlyTrackedFlights lastObject];
        [currentFlight trackWithLocation:[[JustLandedSession sharedSession] lastKnownLocation] 
                             pushEnabled:[[JustLandedSession sharedSession] pushEnabled]];
    }
}

@end
