//
//  Flight.h
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "Airport.h"

typedef enum {
    SCHEDULED,
    ON_TIME,
    DELAYED,
    CANCELED,
    DIVERTED,
    LANDED,
    EARLY    
} FlightStatus;


@interface Flight : NSObject

@property (nonatomic, retain) NSDate *actualArrivalTime;
@property (nonatomic, retain) NSDate *actualDepartureTime;
@property (nonatomic, retain) Airport *destination;
@property (nonatomic, retain) NSString *detailedStatus;
@property (nonatomic, retain) NSDate *estimatedArrivalTime;
@property (nonatomic, retain) NSString *flightID;
@property (nonatomic, retain) NSString *flightNumber;
@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSDate *leaveForAirporTime;
@property (nonatomic, retain) NSString *leaveForAirportRecommendation;
@property (nonatomic, retain) Airport *origin;
@property (nonatomic, retain) NSDate *scheduledDepartureTime;
@property (nonatomic) NSTimeInterval scheduledFlightTime;
@property (nonatomic) FlightStatus status;

+ (void)lookupFlights:(NSString *)flightNumber;
- (id)initWithFlightInfo:(NSDictionary *)info;
- (void)beginTrackingWithLocation:(CLLocation *)loc 
                      pushEnabled:(BOOL)pushFlag;
- (void)updateWithLocation:(CLLocation *)loc;
- (void)stopTracking;

@end
