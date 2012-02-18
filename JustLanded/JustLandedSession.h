//
//  JustLandedSession.h
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const LastKnownLocationDidUpdateNotification;
extern NSString * const LastKnownLocationDidFailToUpdateNotification;


@interface JustLandedSession : NSObject <CLLocationManagerDelegate>

@property (readonly, nonatomic) CLLocation *lastKnownLocation;
@property (copy, nonatomic) NSString *pushToken;

+ (JustLandedSession *)sharedSession;
- (void)startLocationServices;
- (void)stopLocationServices;
- (NSString *)UUID;
- (void)registerForPushNotifications;
- (void)updatePushTokenAfterRegisteringWithApple:(NSString *)token;

@end
