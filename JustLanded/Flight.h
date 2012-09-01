//
//  Flight.h
//  Just Landed
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "OriginAirport.h"
#import "DestinationAirport.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants Associated w/ Flight Class
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
    DAY = 0,
    NIGHT,
} TimeOfDay;

typedef enum {
    SCHEDULED = 0,
    ON_TIME,
    DELAYED,
    CANCELED,
    DIVERTED,
    LANDED,
    EARLY,
    UNKNOWN,
} FlightStatus;

typedef enum {
    FlightFiled = 0,
    FlightDiverted,
    FlightCanceled,
    FlightDeparted,
    FlightArrived,
    FlightChanged,
    LeaveSoonReminder,
    LeaveNowReminder,
    UnknownFlightAlert,
} PushType;

typedef enum {
    JET2 = 0,
    JET2REAR,
    JET4,
    PROP2,
    PROP4
} AircraftType;

typedef enum {
    LookupFailureInvalidFlightNumber,
    LookupFailureFlightNotFound,
    LookupFailureNoConnection,
    LookupFailureError,
    LookupFailureOutage,
} FlightLookupFailedReason;

typedef enum {
    TrackFailureInvalidFlightNumber,
    TrackFailureFlightNotFound,
    TrackFailureOldFlight,
    TrackFailureNoConnection,
    TrackFailureError,
    TrackFailureOutage,
} FlightTrackFailedReason;


extern NSString * const WillLookupFlightNotification;
extern NSString * const DidLookupFlightNotification;
extern NSString * const FlightLookupFailedNotification;
extern NSString * const FlightLookupFailedReasonKey;

extern NSString * const WillTrackFlightNotification;
extern NSString * const DidTrackFlightNotification;
extern NSString * const FlightTrackFailedNotification;
extern NSString * const FlightTrackFailedReasonKey;

extern NSString * const WillStopTrackingFlightNotification;
extern NSString * const DidStopTrackingFlightNotification;
extern NSString * const StopTrackingFlightFailedNotification;
extern NSString * const StopTrackingFailedReasonKey;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flight Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface Flight : NSObject <NSCoding>

// Flight data properties
@property (strong, nonatomic) NSString *flightID;
@property (strong, nonatomic) NSString *flightNumber;
@property (nonatomic) AircraftType aircraftType;
@property (nonatomic) TimeOfDay timeOfDay;

@property (strong, nonatomic) NSDate *actualArrivalTime;
@property (strong, nonatomic) NSDate *actualDepartureTime;
@property (strong, nonatomic) NSDate *estimatedArrivalTime;
@property (strong, nonatomic) NSDate *scheduledDepartureTime;
@property (nonatomic, readonly) NSDate *scheduledArrivalTime; // Derived from other information (readonly)
@property (strong, nonatomic) NSDate *lastUpdated;
@property (strong, nonatomic) NSDate *leaveForAirportTime;
@property (nonatomic) NSTimeInterval drivingTime;
@property (nonatomic) NSTimeInterval scheduledFlightDuration;

@property (strong, nonatomic) OriginAirport *origin;
@property (strong, nonatomic) DestinationAirport *destination;

@property (nonatomic) FlightStatus status;
@property (strong, nonatomic) NSString *detailedStatus;

@property (nonatomic, readonly) NSDate *lastTracked;

+ (NSString *)aircraftTypeToString:(AircraftType)aType;
+ (PushType)stringToPushType:(NSString *)typeString;
+ (void)lookupFlights:(NSString *)aFlightNumber;
- (id)initWithFlightInfo:(NSDictionary *)info;
- (void)trackWithLocation:(CLLocation *)loc pushToken:(NSString *)pushToken;
- (void)stopTracking;
- (NSString *)flightDataAsJson;
- (NSUInteger)minutesBeforeLanding;
- (CGFloat)currentProgress;
- (BOOL)isDataFresh;

@end
