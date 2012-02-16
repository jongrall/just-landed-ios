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

@property (strong, nonatomic) NSDate *actualArrivalTime;
@property (strong, nonatomic) NSDate *actualDepartureTime;
@property (strong, nonatomic) Airport *destination;
@property (strong, nonatomic) NSString *detailedStatus;
@property (strong, nonatomic) NSDate *estimatedArrivalTime;
@property (strong, nonatomic) NSString *flightID;
@property (strong, nonatomic) NSString *flightNumber;
@property (strong, nonatomic) NSDate *lastUpdated;
@property (strong, nonatomic) NSDate *leaveForAirporTime;
@property (strong, nonatomic) NSString *leaveForAirportRecommendation;
@property (strong, nonatomic) Airport *origin;
@property (strong, nonatomic) NSDate *scheduledDepartureTime;
@property (nonatomic) NSTimeInterval scheduledFlightTime;
@property (nonatomic) FlightStatus status;

+ (void)lookupFlights:(NSString *)flightNumber;
- (id)initWithFlightInfo:(NSDictionary *)info;
- (void)trackWithLocation:(CLLocation *)loc pushEnabled:(BOOL)pushFlag;
- (void)stopTracking;

@end
