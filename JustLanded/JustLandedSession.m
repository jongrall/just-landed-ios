//
//  JustLandedSession.m
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//

#import "JustLandedSession.h"
#import "Flight.h"
#import "BWQuincyManager.h"
#import <AudioToolbox/AudioToolbox.h>

NSString * const LastKnownLocationDidUpdateNotification = @"LastKnownLocationUpdatedNotification";
NSString * const LastKnownLocationDidFailToUpdateNotification = @"LocationUpdateFailedNotification";
NSString * const WillRegisterForRemoteNotifications = @"WillRegisterForRemoteNotifications";
NSString * const DidRegisterForRemoteNotifications = @"DidRegisterForRemoteNotifications";
NSString * const DidFailToRegisterForRemoteNotifications = @"DidFailToRegisterForRemoteNotifications";
CLLocationDistance const LOCATION_DISTANCE_FILTER = 150.0;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface JustLandedSession () {
    BOOL _triedToRegisterForRemoteNotifications;
    BOOL _triedToGetLocation;
    __strong NSMutableArray *_currentlyTrackedFlights;
    __strong CLLocation *_lastLocation;
}

@property (strong, nonatomic) CLLocationManager *_locationManager;

- (NSString *)archivedFlightsPath;
- (void)archiveCurrentlyTrackedFlights;
- (NSMutableArray *)unarchiveTrackedFlights;
- (void)deleteArchivedTrackedFlights;
- (void)startBackgroundMonitoring;
- (void)stopBackgroundMonitoring;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation JustLandedSession

@synthesize pushToken;
@synthesize triedToGetLocation=_triedToGetLocation;
@synthesize triedToRegisterForRemoteNotifications=_triedToRegisterForRemoteNotifications;
@synthesize _locationManager;


+ (JustLandedSession *)sharedSession {
    static JustLandedSession *_sharedSession = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedSession = [[self alloc] init];
    });
    
    return _sharedSession;
}


- (id)init {
    self = [super init];
    
    if (self) {
        // Checks file archive to recover any flights we were tracking on a previous run
        _currentlyTrackedFlights = [self unarchiveTrackedFlights];
 
        if (_currentlyTrackedFlights == nil) {
            _currentlyTrackedFlights = [[NSMutableArray alloc] init];
        }
        
        // Archive tracked flights whenever a flight is updated
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(archiveCurrentlyTrackedFlights) 
                                                     name:DidTrackFlightNotification 
                                                   object:nil];
        
        // Track background / return from background events
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(startBackgroundMonitoring) 
                                                     name:UIApplicationDidEnterBackgroundNotification 
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopBackgroundMonitoring) 
                                                     name:UIApplicationDidBecomeActiveNotification 
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Currently Tracked Flights & Archiving Flights
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray *)currentlyTrackedFlights {
    return [NSArray arrayWithArray:_currentlyTrackedFlights];
}


- (void)addTrackedFlight:(Flight *)aFlight {
    if (![_currentlyTrackedFlights containsObject:aFlight]) { // Don't allow duplicates
        [_currentlyTrackedFlights addObject:aFlight];
    
        // Re-archive whenever a new flight is added
        [self archiveCurrentlyTrackedFlights];
    }
}


- (void)removeTrackedFlight:(Flight *)aFlight {
    [_currentlyTrackedFlights removeObject:aFlight];
    
    // Save the changes
    if ([_currentlyTrackedFlights count] > 0) {
        [self archiveCurrentlyTrackedFlights];
    }
    else {
        [self deleteArchivedTrackedFlights];
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
    
    NSURL *archivedFlightsURL = [cacheDirURL URLByAppendingPathComponent:ARCHIVED_FLIGHTS_FILE];
    return [archivedFlightsURL path];
}


- (void)archiveCurrentlyTrackedFlights {
    if (_currentlyTrackedFlights) {
        [NSKeyedArchiver archiveRootObject:_currentlyTrackedFlights toFile:[self archivedFlightsPath]];
    }
}


- (NSMutableArray *)unarchiveTrackedFlights {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivedFlightsPath]];
}


- (void)deleteArchivedTrackedFlights {
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:[self archivedFlightsPath] error:nil]; 
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Location Services & CLLocationManagerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (CLLocationManager *)_locationManager {
    if (!_locationManager) {
        CLLocationManager *locMgr = [[CLLocationManager alloc] init]; 
		locMgr.delegate = self;
		locMgr.desiredAccuracy = kCLLocationAccuracyBest;
        locMgr.distanceFilter = LOCATION_DISTANCE_FILTER;
		locMgr.purpose = NSLocalizedString(@"This lets us estimate your driving time to the airport.",
										   @"Reason we need your location");
		self._locationManager = locMgr;
	}
    
    return _locationManager;
}

- (void)startLocationServices {
    //Create the location manager if needed
	[self._locationManager startUpdatingLocation];
}


- (void)stopLocationServices {
	[self._locationManager stopMonitoringSignificantLocationChanges];
}


- (CLLocation *)lastKnownLocation {
    [self startLocationServices];
    return _lastLocation;
}


- (BOOL)locationServicesAvailable {
    // Application needs both S.L.C.M. and standard location services to be reliable.
    return [CLLocationManager significantLocationChangeMonitoringAvailable] && [CLLocationManager locationServicesEnabled];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // If they later allow location services, get their location
    if (status == kCLAuthorizationStatusAuthorized) {
        [self startLocationServices];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //Notify observers that the location has been updated
    _triedToGetLocation = YES;
    
    // Only report location changes
    if (!_lastLocation || [newLocation distanceFromLocation:_lastLocation] >= LOCATION_DISTANCE_FILTER) {
        _lastLocation = newLocation;
    
    [FlurryAnalytics setLatitude:newLocation.coordinate.latitude 
                       longitude:newLocation.coordinate.longitude 
              horizontalAccuracy:newLocation.horizontalAccuracy 
                verticalAccuracy:newLocation.verticalAccuracy];
	
    NSDictionary *dict = [NSDictionary dictionaryWithObject:newLocation forKey:@"location"];
	[[NSNotificationCenter defaultCenter] postNotificationName:LastKnownLocationDidUpdateNotification 
                                                        object:self 
                                                      userInfo:dict];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    _triedToGetLocation = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:LastKnownLocationDidFailToUpdateNotification object:self];
    [FlurryAnalytics logEvent:FY_UNABLE_TO_GET_LOCATION];
}


- (void)startBackgroundMonitoring {
    if ([_currentlyTrackedFlights count] > 0) {
        // Switch to significant location change monitoring
        [self stopLocationServices];
        
        Flight *currentFlight = [_currentlyTrackedFlights lastObject];
        
        // Monitor their location in the background as long as the flight hasn't already landed or been canceled.
        if (currentFlight.status != LANDED && currentFlight.status != CANCELED) {
            [self._locationManager startMonitoringSignificantLocationChanges];
        }
    }
}


- (void)stopBackgroundMonitoring {
    [self._locationManager stopMonitoringSignificantLocationChanges];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sounds
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)playSound:(JustLandedSoundType)type {
    NSString *soundPath = nil;
    
    switch (type) {
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
    AudioServicesPlaySystemSound (soundID);
}


- (void)vibrateDevice {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push Notifications
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
        [[NSUserDefaults standardUserDefaults] synchronize];
        CFRelease(uuidRef);
    }
    
    return currentUUID;
}


- (void)registerForPushNotifications {
    [[NSNotificationCenter defaultCenter] postNotificationName:WillRegisterForRemoteNotifications object:self];
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}


- (void)didFailToRegisterForRemoteNotifications:(NSError *)error {
    _triedToRegisterForRemoteNotifications = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DidFailToRegisterForRemoteNotifications 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:error 
                                                                                           forKey:@"error"]];
    [FlurryAnalytics logEvent:FY_UNABLE_TO_REGISTER_PUSH];
}


- (void)updatePushTokenAfterRegisteringWithApple:(NSString *)token {
	_triedToRegisterForRemoteNotifications = YES;
    self.pushToken = token;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DidRegisterForRemoteNotifications
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:token
                                                                                           forKey:@"pushToken"]];
}


- (BOOL)pushEnabled {
    // Returns true if alerts are allowed - minimum to consider push enabled for the app (badge & sound not required)
    return ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] & UIRemoteNotificationTypeAlert) && pushToken;
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
    NSNumber *hasBeenAsked = [[NSUserDefaults standardUserDefaults] objectForKey:HasBeenAskedToRateKey];
    
    if (trackCount && !hasBeenAsked) {
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

@end
