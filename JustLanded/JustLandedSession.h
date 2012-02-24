//
//  JustLandedSession.h
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    TakeOffSound = 0,
    AnnouncementSound,
    LandingSound
} JustLandedSoundType;


@class Flight;

extern NSString * const LastKnownLocationDidUpdateNotification;
extern NSString * const LastKnownLocationDidFailToUpdateNotification;


@interface JustLandedSession : NSObject <CLLocationManagerDelegate>

@property (readonly, nonatomic) NSArray *currentlyTrackedFlights;
@property (readonly, nonatomic) CLLocation *lastKnownLocation;
@property (readonly, nonatomic) BOOL pushEnabled;
@property (copy, nonatomic) NSString *pushToken;

+ (JustLandedSession *)sharedSession;
- (void)addTrackedFlight:(Flight *)aFlight;
- (void)removeTrackedFlight:(Flight *)aFlight;

- (void)startLocationServices;
- (void)stopLocationServices;

- (void)playSound:(JustLandedSoundType)type;
- (void)vibrateDevice;

- (NSString *)UUID;
- (void)registerForPushNotifications;
- (void)updatePushTokenAfterRegisteringWithApple:(NSString *)token;

@end
