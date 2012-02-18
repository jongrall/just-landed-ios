//
//  JustLandedSession.m
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//

#import "JustLandedSession.h"

NSString * const LastKnownLocationDidUpdateNotification = @"LastKnownLocationUpdatedNotification";
NSString * const LastKnownLocationDidFailToUpdateNotification = @"LocationUpdateFailedNotification";


@interface JustLandedSession ()

@property (strong, nonatomic) CLLocationManager *_locationManager;

@end



@implementation JustLandedSession

@synthesize pushToken;
@synthesize _locationManager;


+ (JustLandedSession *)sharedSession {
    static JustLandedSession *_sharedSession = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedSession = [[self alloc] init];
    });
    
    return _sharedSession;
}


- (void)startLocationServices {
    //Create the location manager if needed
	if (!self._locationManager) {
		CLLocationManager *locMgr = [[CLLocationManager alloc] init]; 
		locMgr.delegate = self;
		locMgr.desiredAccuracy = kCLLocationAccuracyBest;
		locMgr.purpose = NSLocalizedString(@"With your location Just Landed can estimate your driving time to the airport.",
										   @"Reason we need your location");
		self._locationManager = locMgr;
	}
    
	[self._locationManager startUpdatingLocation];   
}


- (void)stopLocationServices {
	[self._locationManager stopUpdatingLocation];
}


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
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}


- (void)updatePushTokenAfterRegisteringWithApple:(NSString *)token {
	self.pushToken = token;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Custom Accessors / Mutators
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (CLLocation *)lastKnownLocation {
    //If we don't have their last location, or it is too old, update it
    if (_locationManager.location == nil || 
        [[NSDate date] timeIntervalSinceDate:_locationManager.location.timestamp] > DesiredLocationFreshness) {
		[self startLocationServices];
    }
    
    //Return whatever we have
    return _locationManager.location;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {	
	if ([[NSDate date] timeIntervalSinceDate:newLocation.timestamp] > DesiredLocationFreshness) {
        //The location is stale, throw it out
        return;
    }
	
	//Notify observers that the location has been updated
	NSDictionary *dict = [NSDictionary dictionaryWithObject:newLocation forKey:@"location"];
	[[NSNotificationCenter defaultCenter] postNotificationName:LastKnownLocationDidUpdateNotification 
                                                        object:self 
                                                      userInfo:dict];
	
    [self._locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self._locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:LastKnownLocationDidFailToUpdateNotification 
                                                        object:self];
}

@end
