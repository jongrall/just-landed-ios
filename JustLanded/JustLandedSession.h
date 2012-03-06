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
extern NSString * const WillRegisterForRemoteNotifications;
extern NSString * const DidRegisterForRemoteNotifications;
extern NSString * const DidFailToRegisterForRemoteNotifications;


@interface JustLandedSession : NSObject <CLLocationManagerDelegate>

@property (readonly, nonatomic) NSArray *currentlyTrackedFlights;
@property (readonly, nonatomic) CLLocation *lastKnownLocation;
@property (readonly, nonatomic) BOOL pushEnabled;
@property (readonly, nonatomic) BOOL triedToRegisterForRemoteNotifications;
@property (readonly, nonatomic) BOOL triedToGetLocation;
@property (readonly, nonatomic) BOOL locationServicesAvailable;
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
- (void)didFailToRegisterForRemoteNotifications:(NSError *)error;
- (void)updatePushTokenAfterRegisteringWithApple:(NSString *)token;

@end
