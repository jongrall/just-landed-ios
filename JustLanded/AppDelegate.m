//
//  AppDelegate.m
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "FlightLookupViewController.h"
#import "Flight.h"
#import "FlurryAnalytics.h"
#include "Math.h"

NSString * const DidUpdatePushTokenNotification = @"DidUpdatePushTokenNotification";
NSString * const DidFailToUpdatePushTokenNotification = @"DidFailToUpdatePushTokenNotification";

@interface AppDelegate () <BWQuincyManagerDelegate, BWHockeyManagerDelegate, CLLocationManagerDelegate> {
    __strong NSString *_pushToken;
    UIBackgroundTaskIdentifier _wakeupTask;
    BOOL _triedToRegisterForRemoteNotifications;
}

@property (strong, nonatomic) CLLocationManager *_locationManager;
@property (strong, nonatomic) FlightLookupViewController *_mainViewController;

- (void)refreshTrackedFlights;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

@synthesize window = _window;
@synthesize pushToken = _pushToken;
@synthesize triedToRegisterForRemoteNotifications = _triedToRegisterForRemoteNotifications;
@synthesize _locationManager;
@synthesize _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
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
    
    // Configure Flurry
    [FlurryAnalytics startSession:FLURRY_APPLICATION_KEY];
    [FlurryAnalytics setSessionReportsOnPauseEnabled:YES];
    [FlurryAnalytics setSecureTransportEnabled:YES];
    
    // Create the app delegate's location manager
    self._locationManager = [[CLLocationManager alloc] init];
    self._locationManager.delegate = self;
    self._locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self._locationManager.distanceFilter = LOCATION_DISTANCE_FILTER;
    self._locationManager.purpose = NSLocalizedString(@"This lets us estimate your driving time to the airport.",
                                                      @"Location Purpose");
    
    // Register for push notifications
    _pushToken = nil;
    _triedToRegisterForRemoteNotifications = NO;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // The app was launched because of a location change event, start a BG task to give it more time to finish
    _wakeupTask = UIBackgroundTaskInvalid;
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        _wakeupTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:_wakeupTask];
        }];
    }
    
    // Show the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Show the flight lookup UI
    self._mainViewController = [[FlightLookupViewController alloc] init];
    self.window.rootViewController = _mainViewController;
    [self.window makeKeyAndVisible];
    
    // Show previous flights being tracked, if any
    NSArray *prevFlights = [[JustLandedSession sharedSession] currentlyTrackedFlights];
    BOOL isTrackingFlights = [prevFlights count] > 0;
    
    if (isTrackingFlights) {
        // Display the most recently tracked flight
        [_mainViewController beginTrackingFlight:[prevFlights lastObject] animated:NO];
    }
    else {
        [_mainViewController.flightNumberField becomeFirstResponder];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        // Need to update the region being monitored with the new location
        if (isTrackingFlights) {
            [self startMonitoringMovementFromLocation:_locationManager.location];
        }
        [[UIApplication sharedApplication] endBackgroundTask:_wakeupTask];
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
    
    // Disable background location monitoring if prefs demand it
    [[NSUserDefaults standardUserDefaults] synchronize];
    BOOL monitorLocation = [[NSUserDefaults standardUserDefaults] boolForKey:MonitorLocationPreferenceKey];
    BOOL isTrackingFlights = [[[JustLandedSession sharedSession] currentlyTrackedFlights] count] > 0;
    
    if (!monitorLocation || !isTrackingFlights) {
        [self stopMonitoringMovement];
    }
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
            NSString *jsonString = [f flightDataAsJson];
            if (jsonString != nil) {
                [flightData addObject:jsonString];
            }
        }
        
        return [NSString stringWithFormat:@"%@\n\n%@", message_start,
                [flightData componentsJoinedByString:@"\n\n"]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Refreshing Flights
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)refreshTrackedFlights {
    // Uses the device's last location
    for (Flight *f in [[JustLandedSession sharedSession] currentlyTrackedFlights]) {
        [f trackWithLocation:self._locationManager.location pushToken:self.pushToken];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Region / Significant Location Change Monitoring Code
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)startMonitoringMovementFromLocation:(CLLocation *)loc {
    // Only start monitoring for movement if region monitoring is enabled
    if ([CLLocationManager regionMonitoringEnabled]) {
        CLLocationDistance regionRadius = fmin(SIGNIFICANT_LOCATION_CHANGE_DISTANCE, [_locationManager maximumRegionMonitoringDistance]);
        CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:loc.coordinate
                                                                      radius:regionRadius
                                                                  identifier:JustLandedCurrentRegionIdentifier];
        [_locationManager startMonitoringForRegion:newRegion desiredAccuracy:kCLLocationAccuracyBest];
    }
}


- (void)stopMonitoringMovement {
    for (CLRegion *r in [_locationManager monitoredRegions]) {
        if ([r.identifier isEqualToString:JustLandedCurrentRegionIdentifier]) {
            [_locationManager stopMonitoringForRegion:r];
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    BOOL trackingFlights = [[[JustLandedSession sharedSession] currentlyTrackedFlights] count] > 0;
    if (trackingFlights) {
        // Exited region, refresh with the most recent location
        [self refreshTrackedFlights];
        
        // Start monitoring using the new location as the center
        [self startMonitoringMovementFromLocation:_locationManager.location];
    }
    else {
        [self stopMonitoringMovement];
    }
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    switch ([error code]) {
        case kCLErrorRegionMonitoringDenied: {
            // If permission was denied to get location, Apple docs say to stop the location monitor
            [self stopMonitoringMovement];
            break;
        }
        default: {
            break;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    _pushToken = [deviceToken hexString];
    _triedToRegisterForRemoteNotifications = YES;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:DidUpdatePushTokenNotification object:application];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [FlurryAnalytics logEvent:FY_UNABLE_TO_REGISTER_PUSH];
    _triedToRegisterForRemoteNotifications = YES;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:DidFailToUpdatePushTokenNotification object:application];
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
        notification.alertBody = [userInfo valueForKeyPathOrNil:@"aps.alert"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        NSString *notificationType = [userInfo valueForKeyPathOrNil:@"notification_type"];
        
        // Figure out whether they want to hear airplane sounds
        if ([[JustLandedSession sharedSession] wantsToHearFlightSounds]) {
            // Play the right sound - UILocalNotification won't always play the sound
            if (notificationType) {
                PushType type = [Flight stringToPushType:notificationType];
                
                switch (type) {
                    case FlightDeparted:
                        [[JustLandedSession sharedSession] playSound:TakeOffSound];
                        break;
                    case FlightArrived:
                        [[JustLandedSession sharedSession] playSound:LandingSound];
                        break;
                    default:
                        [[JustLandedSession sharedSession] playSound:AnnouncementSound];
                        break;
                }
            }
            else {
                [[JustLandedSession sharedSession] playSound:AnnouncementSound];
            }
        }
        
        // Always vibrate on update
        [[JustLandedSession sharedSession] vibrateDevice];
        
        // Refresh the flight information
        [self refreshTrackedFlights];
    }
}

@end
