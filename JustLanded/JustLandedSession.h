//
//  Just LandedSession.h
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    TakeOffSound = 0,
    AnnouncementSound,
    LandingSound
} JustLandedSoundType;


@class Flight;

extern NSString * const LastKnownLocationDidUpdateNotification;
extern NSString * const LastKnownLocationDidFailToUpdateNotification;
extern NSString * const WillRegisterForRemoteNotifications;
extern NSString * const DidRegisterForRemoteNotifications;
extern NSString * const DidFailToRegisterForRemoteNotifications;


@interface JustLandedSession : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate >

@property (readonly, nonatomic) NSArray *currentlyTrackedFlights;
@property (readonly, nonatomic) CLLocation *lastKnownLocation;
@property (readonly, nonatomic) BOOL locationServicesAvailable;
@property (readonly, nonatomic) BOOL pushEnabled;
@property (readonly, nonatomic) BOOL triedToRegisterForRemoteNotifications;
@property (readonly, nonatomic) BOOL triedToGetLocation;
@property (readonly, nonatomic) NSUInteger trackCount;
@property (copy, nonatomic) NSString *pushToken;

+ (JustLandedSession *)sharedSession;

// User management & prefs
- (NSString *)UUID;
- (NSMutableDictionary *)currentTrackingPreferences;

// App ratings
- (void)incrementTrackCount;
- (BOOL)isEligibleToRate;
- (void)showRatingRequestIfEligible;

// Flight management
- (void)addTrackedFlight:(Flight *)aFlight;
- (void)removeTrackedFlight:(Flight *)aFlight;
- (void)refreshTrackedFlights;
- (NSArray *)recentlyLookedUpAirlines;
- (void)addToRecentlyLookedUpAirlines:(NSDictionary *)airlineInfo;
- (void)clearRecentlyLookedUpAirlines;

// Push notifications & associated sounds
- (void)registerForPushNotifications;
- (void)didFailToRegisterForRemoteNotifications:(NSError *)error;
- (void)updatePushTokenAfterRegisteringWithApple:(NSString *)token;
- (void)playSound:(JustLandedSoundType)type;
- (void)vibrateDevice;
- (BOOL)wantsToHearFlightSounds;

// Connectivity Testing
- (BOOL)isJustLandedReachable;

@end
