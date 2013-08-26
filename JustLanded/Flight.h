//
//  Flight.h
//  Just Landed
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import "OriginAirport.h"
#import "DestinationAirport.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants Associated w/ Flight Class
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, TimeOfDay) {
    DAY = 0,
    NIGHT,
};

typedef NS_ENUM(NSUInteger, FlightStatus) {
    SCHEDULED = 0,
    ON_TIME,
    DELAYED,
    CANCELED,
    DIVERTED,
    LANDED,
    EARLY,
    UNKNOWN,
};

typedef NS_ENUM(NSUInteger, PushType) {
    FlightFiled = 0,
    FlightDiverted,
    FlightCanceled,
    FlightDeparted,
    FlightArrived,
    FlightChanged,
    LeaveSoonReminder,
    LeaveNowReminder,
    UnknownFlightAlert,
};

typedef NS_ENUM(NSUInteger, AircraftType) {
    JET2 = 0,
    JET2REAR,
    JET4,
    PROP2,
    PROP4
};

typedef NS_ENUM(NSUInteger, FlightLookupFailedReason) {
    LookupFailureInvalidFlightNumber = 0,
    LookupFailureFlightNotFound,
    LookupFailureNoCurrentFlight,
    LookupFailureNoConnection,
    LookupFailureError,
    LookupFailureOutage,
};

typedef NS_ENUM(NSUInteger, FlightTrackFailedReason) {
    TrackFailureInvalidFlightNumber = 0,
    TrackFailureFlightNotFound,
    TrackFailureOldFlight,
    TrackFailureNoConnection,
    TrackFailureError,
    TrackFailureOutage,
};


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
@property (copy, nonatomic) NSString *flightID;
@property (copy, nonatomic) NSString *flightNumber;
@property (nonatomic) AircraftType aircraftType;
@property (nonatomic) TimeOfDay timeOfDay;

@property (strong, nonatomic) NSDate *actualArrivalTime;
@property (strong, nonatomic) NSDate *actualDepartureTime;
@property (strong, nonatomic) NSDate *estimatedArrivalTime;
@property (strong, nonatomic) NSDate *scheduledDepartureTime;
@property (strong, readonly, nonatomic) NSDate *scheduledArrivalTime;
@property (strong, nonatomic) NSDate *lastUpdated;
@property (strong, nonatomic) NSDate *leaveForAirportTime;
@property (nonatomic) NSTimeInterval drivingTime;
@property (nonatomic) NSTimeInterval scheduledFlightDuration;

@property (strong, nonatomic) OriginAirport *origin;
@property (strong, nonatomic) DestinationAirport *destination;

@property (nonatomic) FlightStatus status;
@property (copy, nonatomic) NSString *detailedStatus;

@property (strong, readonly, nonatomic) NSDate *lastTracked;

+ (NSString *)aircraftTypeToString:(AircraftType)anAircraftType;
+ (PushType)stringToPushType:(NSString *)aPushTypeString;
+ (void)lookupFlights:(NSString *)aFlightNumber;
- (id)initWithFlightInfo:(NSDictionary *)someFlightInfo;
- (void)trackWithLocation:(CLLocation *)aLocation pushToken:(NSString *)pushToken;
- (void)stopTracking;
- (NSString *)flightDataAsJson;
- (NSUInteger)minutesBeforeLanding;
- (CGFloat)currentProgress;
- (BOOL)isDataFresh;

@end
