//
//  Just LandedSession.h
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JustLandedSoundType) {
    TakeOffSound = 0,
    AnnouncementSound,
    LandingSound
};

@class Flight;

@interface JustLandedSession : NSObject

+ (JustLandedSession *)sharedSession;

// User management & prefs
- (NSString *)UUID;
- (NSMutableDictionary *)currentTrackingPreferences;

// App ratings
- (void)incrementTrackCount;
- (BOOL)isEligibleToRate;
- (void)showRatingRequestIfEligible;

// Flight management
- (NSArray *)currentlyTrackedFlights;
- (void)addTrackedFlight:(Flight *)aFlight;
- (void)removeTrackedFlight:(Flight *)aFlight;
- (NSArray *)recentlyLookedUpAirlines;
- (void)addToRecentlyLookedUpAirlines:(NSDictionary *)airlineInfo;
- (void)clearRecentlyLookedUpAirlines;

// Sounds
- (void)playSound:(JustLandedSoundType)soundType;
- (BOOL)wantsToHearFlightSounds;

// Connectivity Testing
- (BOOL)isJustLandedReachable;

@end
