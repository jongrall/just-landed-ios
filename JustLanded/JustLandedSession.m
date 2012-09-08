//
//  Just LandedSession.m
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JustLandedSession.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Flight.h"
#import "BWQuincyManager.h"
#import "Reachability.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface JustLandedSession () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *currentlyTrackedFlights_;

- (NSString *)archivedFlightsPath;
- (void)archiveCurrentlyTrackedFlights;
- (NSMutableArray *)unarchiveTrackedFlights;
- (void)deleteArchivedTrackedFlights;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation JustLandedSession

@synthesize currentlyTrackedFlights_;

+ (JustLandedSession *)sharedSession {
    static JustLandedSession *sSharedSession_ = nil;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        sSharedSession_ = [[self alloc] init];
    });
    
    return sSharedSession_;
}


- (id)init {
    self = [super init];
    
    if (self) {
        // Checks file archive to recover any flights we were tracking on a previous run
        self.currentlyTrackedFlights_ = [self unarchiveTrackedFlights];
 
        if (self.currentlyTrackedFlights_ == nil) {
            self.currentlyTrackedFlights_ = [[NSMutableArray alloc] init];
        }
        
        // Register default preferences (not automatically pulled in from Settings.bundle defaults
        NSDictionary *defaultPrefs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], SendFlightEventsPreferenceKey,
                                      [NSNumber numberWithBool:YES], SendRemindersPreferenceKey,
                                      [NSNumber numberWithInt:300], ReminderLeadTimePreferenceKey,
                                      [NSNumber numberWithBool:YES], PlayFlightSoundsPreferenceKey,
                                      [NSNumber numberWithBool:YES], MonitorLocationPreferenceKey, nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
        
        // Archive tracked flights whenever any flight is updated
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(archiveCurrentlyTrackedFlights) 
                                                     name:DidTrackFlightNotification 
                                                   object:nil];
    }
    return self;
}


- (void)dealloc {
    // Note: Should never be called since singleton, but implemented anyway
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - User Management & Prefs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)UUID {
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDKey];
    
    if (!currentUUID) {
        //Should only be run once for a single install unless NSUserDefaults gets cleared or corrupted
        //Create the UUID to use for the app (persists across sessions) and persist to NSUserDefaults
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        currentUUID = [NSString stringWithString:uuid];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:UUIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:BeganUsingDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        CFRelease(uuidRef);
    }
    
    return currentUUID;
}


- (NSMutableDictionary *)currentTrackingPreferences {
    // Force refresh of pref caches
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Get the prefs
    BOOL sendFlightEvents = [[NSUserDefaults standardUserDefaults] boolForKey:SendFlightEventsPreferenceKey];
    BOOL sendReminders = [[NSUserDefaults standardUserDefaults] boolForKey:SendRemindersPreferenceKey];
    BOOL playFlightSounds = [[NSUserDefaults standardUserDefaults] boolForKey:PlayFlightSoundsPreferenceKey];
    NSUInteger reminderLeadTime = [[NSUserDefaults standardUserDefaults] integerForKey:ReminderLeadTimePreferenceKey];
    
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:sendFlightEvents], SendFlightEventsPreferenceKey,
            [NSNumber numberWithBool:sendReminders], SendRemindersPreferenceKey,
            [NSNumber numberWithBool:playFlightSounds], PlayFlightSoundsPreferenceKey,
            [NSNumber numberWithInteger:reminderLeadTime], ReminderLeadTimePreferenceKey, nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - App Ratings
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)incrementTrackCount {
    NSNumber *trackCount = [[NSUserDefaults standardUserDefaults] objectForKey:FlightsTrackedCountKey];
    
    if (trackCount) {
        NSUInteger newCount = [trackCount integerValue] + 1;
        trackCount = [NSNumber numberWithInt:newCount];
    }
    else {
        trackCount = [NSNumber numberWithInt:1];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:trackCount forKey:FlightsTrackedCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)isEligibleToRate {
    NSNumber *trackCount = [[NSUserDefaults standardUserDefaults] objectForKey:FlightsTrackedCountKey];
    BOOL hasBeenAsked = [[[NSUserDefaults standardUserDefaults] objectForKey:HasBeenAskedToRateKey] boolValue];
    NSDate *beganUsing = [[NSUserDefaults standardUserDefaults] objectForKey:BeganUsingDate];
    BOOL oldEnoughUser = beganUsing && [[NSDate date] timeIntervalSinceDate:beganUsing] > (3.0 * 86400.0);
    BOOL appInForeground = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    
    if (trackCount && !hasBeenAsked && oldEnoughUser && appInForeground) {
        NSUInteger currentCount = [trackCount integerValue];
        
        if (currentCount >= RATINGS_USAGE_THRESHOLD && ![[BWQuincyManager sharedQuincyManager] didCrashInLastSession]) {
            return YES;
        }
    }
    
    return NO;
}


- (void)showRatingRequestIfEligible {
    if ([self isEligibleToRate]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enjoying Just Landed?", @"Ratings Alert Title")
                                                        message:NSLocalizedString(@"We'd appreciate it if you'd give us a good rating on the App Store.", @"Ratings Alert Body")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No Thanks", @"No Thanks")
                                              otherButtonTitles:NSLocalizedString(@"Sure", @"Sure") , nil];
        
        // Mark them as having been asked, prevents multiple alerts
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:HasBeenAskedToRateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [alert show];
        [FlurryAnalytics logEvent:FY_ASKED_TO_RATE];
    }
}

// Handle ratings alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] != buttonIndex) {
        NSURL *ratingURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", APP_ID]];
        [[UIApplication sharedApplication] openURL:ratingURL];
        [FlurryAnalytics logEvent:FY_RATED];
    }
    else {
        [FlurryAnalytics logEvent:FY_DECLINED_TO_RATE];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flight management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray *)currentlyTrackedFlights {
    return [NSArray arrayWithArray:self.currentlyTrackedFlights_];
}


- (void)addTrackedFlight:(Flight *)aFlight {
    if (![self.currentlyTrackedFlights_ containsObject:aFlight]) { // Don't allow duplicates
        [self.currentlyTrackedFlights_ addObject:aFlight];
        
        // Untrack any flights that are not the current one
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (Flight *f in self.currentlyTrackedFlights_) {
            if (f != aFlight) {
                [f stopTracking];
                [toRemove addObject:f];
            }
        }
        
        [self.currentlyTrackedFlights_ removeObjectsInArray:toRemove];
    
        // Re-archive whenever a new flight is added
        [self archiveCurrentlyTrackedFlights];
    }
}


- (void)removeTrackedFlight:(Flight *)aFlight {
    [self.currentlyTrackedFlights_ removeObject:aFlight];
    
    // Save the changes
    if ([self.currentlyTrackedFlights_ count] > 0) {
        [self archiveCurrentlyTrackedFlights];
    }
    else {
        self.currentlyTrackedFlights_ = [[NSMutableArray alloc] init];
        [self deleteArchivedTrackedFlights];
                
        // Hack to clear past notifications from the notification center
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}


- (NSString *)archivedFlightsPath {
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *urls = [mgr URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDirURL = nil;
    
    @try {
        cacheDirURL = [urls objectAtIndex:0];
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    NSURL *archivedFlightsURL = [cacheDirURL URLByAppendingPathComponent:ArchivedFlightsFile];
    return [archivedFlightsURL path];
}


- (void)archiveCurrentlyTrackedFlights {
    if (self.currentlyTrackedFlights_) {
        [NSKeyedArchiver archiveRootObject:self.currentlyTrackedFlights_ toFile:[self archivedFlightsPath]];
    }
}


- (NSMutableArray *)unarchiveTrackedFlights {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivedFlightsPath]];
}


- (void)deleteArchivedTrackedFlights {
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:[self archivedFlightsPath] error:nil];
}


- (NSArray *)recentlyLookedUpAirlines {
    NSArray *airlines = [[NSUserDefaults standardUserDefaults] objectForKey:RecentAirlineLookupsKey];
    
    if (airlines) {
        return airlines;
    }
    else {
        return [[NSArray alloc] init];
    }
}


- (void)addToRecentlyLookedUpAirlines:(NSDictionary *)airlineInfo {
    NSArray *currentAirlines = [[NSUserDefaults standardUserDefaults] objectForKey:RecentAirlineLookupsKey];
    
    if (currentAirlines) {
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        
        for (NSDictionary *airline in currentAirlines) {
            if ([(NSString *)[airline valueForKeyOrNil:@"icao"] isEqualToString:[airlineInfo valueForKeyOrNil:@"icao"]]) {
                [toRemove addObject:airline];
            }
        }
        
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:currentAirlines];
        [newArray removeObjectsInArray:toRemove];
        [newArray insertObject:airlineInfo atIndex:0];
        
        if ([newArray count] > 5) {
            newArray = [[newArray subarrayWithRange:NSMakeRange(0, 5)] mutableCopy]; // No more than 5 recent
        }
        [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:RecentAirlineLookupsKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:airlineInfo] forKey:RecentAirlineLookupsKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)clearRecentlyLookedUpAirlines {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:RecentAirlineLookupsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sounds
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)playSound:(JustLandedSoundType)soundType {
    NSString *soundPath = nil;
    
    switch (soundType) {
        case TakeOffSound:
            soundPath = [[NSBundle mainBundle] pathForResource:@"takeoff" ofType:@"wav"];
            break;
        case LandingSound:
            soundPath = [[NSBundle mainBundle] pathForResource:@"landing" ofType:@"wav"];
            break;
        default:
            soundPath = [[NSBundle mainBundle] pathForResource:@"announcement" ofType:@"wav"];
            break;
    }
    
    SystemSoundID soundID;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    
    // Plays sounds & invokes vibration if appropriate
    AudioServicesPlayAlertSound (soundID);
}


- (BOOL)wantsToHearFlightSounds {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] boolForKey:PlayFlightSoundsPreferenceKey];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Connectivity Testing
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isJustLandedReachable {
    return [[Reachability reachabilityWithHostname:JL_HOST_NAME] isReachable];
}

@end
