//
//  AppDelegate.m
//  Just Landed
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "FlightLookupViewController.h"
#import "Flight.h"
#import <HockeySDK/HockeySDK.h>
#include "Math.h"

NSString * const DidUpdatePushTokenNotification = @"DidUpdatePushTokenNotification";
NSString * const DidFailToUpdatePushTokenNotification = @"DidFailToUpdatePushTokenNotification";

@interface AppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate, CLLocationManagerDelegate>

// Redefine as readwrite
@property (copy, readwrite, nonatomic) NSString *pushToken;
@property (readwrite, nonatomic) BOOL triedToRegisterForRemoteNotifications;

@property (strong, nonatomic) CLLocationManager *locationManager_;
@property (strong, nonatomic) FlightLookupViewController *mainViewController_;

- (void)trackFlightsIfNeeded;
- (void)beginWakeupTask;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialization
    self.pushToken = nil;
    self.wakeupTrackTask = UIBackgroundTaskInvalid;
    
    // App Development and Crash reporting
    #ifndef CONFIGURATION_Debug
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:HOCKEY_APP_ID_ADHOC
                                                         liveIdentifier:HOCKEY_APP_ID_PRODUCTION
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[[BITHockeyManager sharedHockeyManager] crashManager] setCrashManagerStatus:BITCrashManagerStatusAutoSend]; // Auto send crashes
    #endif
    
    // Configure Flurry
    [Flurry startSession:FLURRY_APPLICATION_KEY];
    [Flurry setSessionReportsOnPauseEnabled:YES];
    [Flurry setSecureTransportEnabled:YES];
        
    // Create the app delegate's location manager
    self.locationManager_ = [[CLLocationManager alloc] init];
    self.locationManager_.delegate = self;
    self.locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager_.distanceFilter = LOCATION_DISTANCE_FILTER;
    if ([self.locationManager_ respondsToSelector:@selector(setPurpose:)]) {
        // Deprecated but desired API
        self.locationManager_.purpose = NSLocalizedString(@"This lets us estimate your driving time to the airport.",
                                                          @"Location Purpose");
    }
    // Stop monitoring significant location changes in case they just upgraded from previous version (otherwise could get stuck on)
    [self.locationManager_ stopMonitoringSignificantLocationChanges];
    
    
    NSArray *prevFlights = [[JustLandedSession sharedSession] currentlyTrackedFlights];
    BOOL isTrackingFlights = [prevFlights count] > 0;
    
    // Register for push notifications
    self.triedToRegisterForRemoteNotifications = NO;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // The app was launched because of a location change event, and they are tracking flights start a BG task to give it more time to finish
    if (launchOptions[UIApplicationLaunchOptionsLocationKey] && isTrackingFlights) {        
        [self beginWakeupTask];
    }
    // The app was launched because of a local notification
    else if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        if (notification && [[notification userInfo][LocalNotificationTypeKey] integerValue] == JLLocalNotificationTypeTextOnArrival) {
            self.respondedToTextOnArrivalNotification = YES;
        }
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Show the flight lookup UI
    self.mainViewController_ = [[FlightLookupViewController alloc] init];
    self.window.rootViewController = self.mainViewController_;
    [self.window makeKeyAndVisible];
    
    // Show previous flights being tracked, if any    
    if (isTrackingFlights) {
        // Display the most recently tracked flight
        [self.mainViewController_ beginTrackingFlight:[prevFlights lastObject] animated:NO];
    }
    else {
        [self.mainViewController_.flightNumberField becomeFirstResponder];
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
    if (!monitorLocation) {
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Device Identifier Required by BITUpdateManagerDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
    #ifdef CONFIGURATION_Adhoc
    return [[JustLandedSession sharedSession] UUID];
    #endif
    return nil;
}

- (NSString *)userNameForCrashManager:(BITCrashManager *)crashManager {
    return [[JustLandedSession sharedSession] UUID];
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
#pragma mark - Region / Significant Location Change Monitoring Code
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)beginWakeupTask {
    if (self.wakeupTrackTask == UIBackgroundTaskInvalid) { // Only start if no similar bg task is in progress
        self.wakeupTrackTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            // Emergency task expiration handler to prevent app getting killed
            [[UIApplication sharedApplication] endBackgroundTask:self.wakeupTrackTask];
            self.wakeupTrackTask = UIBackgroundTaskInvalid;
        }];
    }
}


- (void)startMonitoringMovementFromLocation:(CLLocation *)aLocation {
    // Only start monitoring for movement if region monitoring is enabled
    if ([CLLocationManager regionMonitoringEnabled]) {
        CLLocationDistance regionRadius = fmin(SIGNIFICANT_LOCATION_CHANGE_DISTANCE, [self.locationManager_ maximumRegionMonitoringDistance]);
        CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:aLocation.coordinate
                                                                      radius:regionRadius
                                                                  identifier:JustLandedCurrentRegionIdentifier];
        [self.locationManager_ startMonitoringForRegion:newRegion];
    }
}


- (void)stopMonitoringMovement {
    // Stops monitoring movement from the user's last location
    for (CLRegion *r in [self.locationManager_ monitoredRegions]) {
        if ([r.identifier isEqualToString:JustLandedCurrentRegionIdentifier]) {
            [self.locationManager_ stopMonitoringForRegion:r];
        }
    }
}


- (void)trackFlightsIfNeeded {
    // Tracks flights using the active FlightTrackViewController, if one exists
    BOOL isTrackingFlights = [[[JustLandedSession sharedSession] currentlyTrackedFlights] count] > 0;
    
    if (isTrackingFlights) {
        if (self.mainViewController_) {
            UIViewController *possibleTrackVC = self.mainViewController_.presentedViewController;
            if (possibleTrackVC && [possibleTrackVC isKindOfClass:[FlightTrackViewController class]]) {
                [(FlightTrackViewController *)possibleTrackVC track];
            }
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    // Only do something if it's the region we're interested in
    if ([region.identifier isEqualToString:JustLandedCurrentRegionIdentifier]) {
        BOOL trackingFlights = [[[JustLandedSession sharedSession] currentlyTrackedFlights] count] > 0;
        if (trackingFlights) {
            [self beginWakeupTask];
            
            // Start monitoring using the new location as the center (may be updated again or removed after /track or /untrack)
            [self startMonitoringMovementFromLocation:self.locationManager_.location];
            
            // Exited region, track flights by getting their location
            [self trackFlightsIfNeeded];
        }
        else {
            // If we're somehow still monitoring a region but no longer tracking flights, stop monitoring
            [self stopMonitoringMovement];
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    // Only do something if it's the region we're interested in
    if ([region.identifier isEqualToString:JustLandedCurrentRegionIdentifier]) {
        switch ([error code]) {
            case kCLErrorRegionMonitoringDenied: {
                // If permission was denied to get location, Apple docs say to stop trying
                [self stopMonitoringMovement];
                break;
            }
            default: {
                break;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.pushToken = [deviceToken hexString];
    self.triedToRegisterForRemoteNotifications = YES;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:DidUpdatePushTokenNotification object:application];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    self.triedToRegisterForRemoteNotifications = YES;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:DidFailToUpdatePushTokenNotification object:application];
    [Flurry logEvent:FY_UNABLE_TO_REGISTER_PUSH];
    NSLog(@"Just Landed failed to register for remote notifications: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Only alert them if they haven't been told yet and they are still tracking flights.
    // (UIApplicationStateInactive indicates the app was launched in
    // response to the user tapping the action button of the push notification).
    BOOL isTrackingFlights = [[[JustLandedSession sharedSession] currentlyTrackedFlights] count] > 0;
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
            // Play the right sound - UILocalNotification won't play the sound in this context
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
        
        // Track the active flight (if there is one)
        [self trackFlightsIfNeeded];
    }
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateInactive) {
        // App posted local notification, user acted on it
        if ([[[notification userInfo] valueForKeyOrNil:LocalNotificationTypeKey] integerValue] == JLLocalNotificationTypeTextOnArrival) {
            self.respondedToTextOnArrivalNotification = YES;
        }
    }
}

@end
