//
//  Flight.h
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "OriginAirport.h"
#import "DestinationAirport.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants Associated w/ Flight Class
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
} FlightLookupFailedReason;

typedef enum {
    TrackFailureInvalidFlightNumber,
    TrackFailureFlightNotFound,
    TrackFailureOldFlight,
    TrackFailureNoConnection,
    TrackFailureError,
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

@property (strong, nonatomic) NSDate *actualArrivalTime;
@property (strong, nonatomic) NSDate *actualDepartureTime;
@property (strong, nonatomic) NSDate *estimatedArrivalTime;
@property (strong, nonatomic) NSDate *scheduledDepartureTime;
@property (nonatomic, readonly) NSDate *scheduledArrivalTime; // Derived from other information (readonly)
@property (strong, nonatomic) NSDate *lastUpdated;
@property (strong, nonatomic) NSDate *leaveForAirporTime;
@property (nonatomic) NSTimeInterval scheduledFlightDuration;

@property (strong, nonatomic) OriginAirport *origin;
@property (strong, nonatomic) DestinationAirport *destination;

@property (nonatomic) FlightStatus status;
@property (strong, nonatomic) NSString *detailedStatus;

@property (nonatomic, readonly) NSDate *lastTracked;

+ (PushType)stringToPushType:(NSString *)typeString;
+ (void)lookupFlights:(NSString *)aFlightNumber;
- (id)initWithFlightInfo:(NSDictionary *)info;
- (void)trackWithLocation:(CLLocation *)loc pushEnabled:(BOOL)pushFlag;
- (void)stopTracking;
- (NSString *)flightDataAsJson;

@end
