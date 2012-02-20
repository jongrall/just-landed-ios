//
//  Flight.m
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "Flight.h"


NSString * const WillLookupFlightNotification = @"WillLookupFlightNotification";
NSString * const DidLookupFlightNotification = @"DidLookupFlightNotification";
NSString * const FlightLookupFailedNotification = @"FlightLookupFailedNotification";
NSString * const FlightLookupFailedReasonKey = @"FlightLookupFailedReasonKey";

NSString * const WillTrackFlightNotification = @"WillTrackFlightNotification";
NSString * const DidTrackFlightNotification = @"DidTrackFlightNotification";
NSString * const FlightTrackFailedNotification = @"FlightTrackFailedNotification";
NSString * const FlightTrackFailedReasonKey = @"FlightTrackFailedReasonKey";


@interface Flight () 

@property (nonatomic) BOOL _didBeginTracking;

+ (NSString *)lookupPath:(NSString *)flightNumber;
- (NSString *)trackPath;
- (NSString *)stopTrackingPath;
- (void)updateWithFlightInfo:(NSDictionary *)info;
        
@end


@implementation Flight

@synthesize actualArrivalTime;
@synthesize actualDepartureTime;
@synthesize destination;
@synthesize detailedStatus;
@synthesize _didBeginTracking;
@synthesize estimatedArrivalTime;
@synthesize flightID;
@synthesize flightNumber;
@synthesize lastUpdated;
@synthesize leaveForAirporTime;
@synthesize leaveForAirportRecommendation;
@synthesize origin;
@synthesize scheduledDepartureTime;
@synthesize scheduledFlightTime;
@synthesize status;

static NSArray *_statuses;

+ (void)initialize {
	if (self == [Flight class]) {
        _statuses = [[NSArray alloc] initWithObjects:@"SCHEDULED",
                     @"ON_TIME",
                     @"DELAYED",
                     @"CANCELED",
                     @"DIVERTED",
                     @"LANDED",
                     @"EARLY",
                     @"UNKNOWN", nil];
	}
}

+ (NSString *)lookupPath:(NSString *)flightNumber {
    return [[NSString stringWithFormat:LOOKUP_URL_FORMAT, flightNumber] 
            stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];;
}


- (NSString *)trackPath {
    return [[NSString stringWithFormat:TRACK_URL_FORMAT, self.flightNumber, self.flightID] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}


- (NSString *)stopTrackingPath {
    return [[NSString stringWithFormat:UNTRACK_URL_FORMAT, self.flightID]
            stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}


+ (void)lookupFlights:(NSString *)aFlightNumber {
    [[NSNotificationCenter defaultCenter] postNotificationName:WillLookupFlightNotification object:nil];
    
    NSString *lookupPath = [self lookupPath:aFlightNumber];
    
    [[JustLandedAPIClient sharedClient] getPath:lookupPath 
         parameters:nil 
            success:^(AFHTTPRequestOperation *operation, id JSON){                
                if (JSON && [JSON isKindOfClass:[NSArray class]]) {
                    NSArray *listOfFlightInfo = (NSArray *)JSON;
                    
                    // Got the flight data, return a list of flights
                    NSMutableArray *listOfFlights = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *info in listOfFlightInfo) {
                        [listOfFlights addObject:[[Flight alloc] initWithFlightInfo:info]];
                    }
                    
                    NSDictionary *flights = [NSDictionary dictionaryWithObjectsAndKeys:listOfFlights, @"flights", nil];
                    
                    // Post success notification with fetched flights attached
                    [[NSNotificationCenter defaultCenter] postNotificationName:DidLookupFlightNotification 
                                                                        object:nil
                                                                      userInfo:flights];
                }

            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {                
                NSHTTPURLResponse *response = [operation response];
                NSLog(@"FAILED");
                
                if (response) {
                    NSLog(@"GOT RESPONSE");
                    NSMutableDictionary *reasonDict = [[NSMutableDictionary alloc] init];
                    
                    switch ([response statusCode]) {
                        case 400:
                            // Invalid flight number
                            [reasonDict setValue:[NSNumber numberWithInt:LookupFailureInvalidFlightNumber]
                                          forKey:FlightLookupFailedReasonKey];
                            break;
                        case 404:
                            // Flight not found
                            [reasonDict setValue:[NSNumber numberWithInt:LookupFailureFlightNotFound]
                                          forKey:FlightLookupFailedReasonKey];
                            break;
                        default:
                            break;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FlightLookupFailedNotification 
                                                                        object:nil 
                                                                      userInfo:reasonDict];
                }
                else {
                    // TODO: Handle connection problem
                    NSLog(@"NO RESPONSE");
                }
            }];
}


- (id)initWithFlightInfo:(NSDictionary *)info {
    self = [super init];
    
    if (self && info) {
        [self updateWithFlightInfo:info];
        return self;
    }
    return nil;
}



- (void)updateWithFlightInfo:(NSDictionary *)info {
    // Process and set all the flight information
    self.actualArrivalTime = [[info valueForKeyOrNil:@"actualArrivalTime"] integerValue] > 0 ?
        [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"actualArrivalTime"]] : nil;
    
    self.actualDepartureTime = [[info valueForKeyOrNil:@"actualDepartureTime"] integerValue] > 0 ?
        [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"actualDepartureTime"]] : nil;
    
    // Setup destination & origin
    self.destination = [[Airport alloc] initWithAirportInfo:[info valueForKeyOrNil:@"destination"]];
    self.destination.isDestination = YES;
    self.origin = [[Airport alloc] initWithAirportInfo:[info valueForKeyOrNil:@"origin"]];
    
    self.detailedStatus = [info valueForKeyOrNil:@"detailedStatus"];
    
    self.estimatedArrivalTime = [[info valueForKeyOrNil:@"estimatedArrivalTime"] integerValue] > 0 ?
        [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"estimatedArrivalTime"]] : nil;
    
    self.flightID = [info valueForKeyOrNil:@"flightID"];
    self.flightNumber = [info valueForKeyOrNil:@"flightNumber"];
    
    self.lastUpdated = [[info valueForKeyOrNil:@"lastUpdated"] integerValue] > 0 ?
        [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"lastUpdated"]] : nil;
    
    self.leaveForAirporTime = [[info valueForKeyOrNil:@"leaveForAirportTime"] integerValue] > 0 ?
        [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"leaveForAirportTime"]] : nil;
    
    self.leaveForAirportRecommendation = [info valueForKeyOrNil:@"leaveForAirportRecommendation"];
    
    self.scheduledDepartureTime = [[info valueForKeyOrNil:@"scheduledDepartureTime"] integerValue] > 0 ?
        [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"scheduledDepartureTime"]] : nil;
    
    self.scheduledFlightTime = [[info valueForKeyOrNil:@"scheduledFlightTime"] doubleValue];
    
    NSUInteger parsed_status = [_statuses indexOfObject:[info valueForKeyOrNil:@"status"]];
    if (parsed_status == NSNotFound) {
        self.status = UNKNOWN;
    }
    else {
        self.status = parsed_status;
    }
}


- (void)trackWithLocation:(CLLocation *)loc pushEnabled:(BOOL)pushFlag {
    [[NSNotificationCenter defaultCenter] postNotificationName:WillTrackFlightNotification object:self];
    
    NSString *trackingPath = [self trackPath];
    NSDictionary *trackingParams = nil;
    
    if (loc) {
        trackingParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"latitude", [NSNumber numberWithFloat:loc.coordinate.latitude],
                          @"longitude", [NSNumber numberWithFloat:loc.coordinate.longitude],
                          @"begin_tracking", !self._didBeginTracking,
                          @"push", [NSNumber numberWithBool:pushFlag], nil]; 
    }
    else {
        trackingParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"begin_tracking", !self._didBeginTracking,
                          @"push", [NSNumber numberWithBool:pushFlag], nil]; 
    }
    
    [[JustLandedAPIClient sharedClient] getPath:trackingPath 
         parameters:trackingParams 
            success:^(AFHTTPRequestOperation *operation, id JSON){
                // TODO: Implement me
                if (JSON && [JSON isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *flightInfo = (NSDictionary *)JSON;
                    [self updateWithFlightInfo:flightInfo];
                    
                    // beginTracking flag is set only once for this instance
                    if (!self._didBeginTracking) {
                        self._didBeginTracking = YES;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:DidTrackFlightNotification object:self];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSHTTPURLResponse *response = [operation response];
                NSMutableDictionary *reasonDict = [[NSMutableDictionary alloc] init];
                
                if (response) {
                    switch ([response statusCode]) {
                        case 400:
                            // Invalid flight number
                            [reasonDict setValue:[NSNumber numberWithInt:TrackFailureInvalidFlightNumber] 
                                                                  forKey:FlightLookupFailedReasonKey];
                            break;
                        case 404:
                            // Flight not found
                            [reasonDict setValue:[NSNumber numberWithInt:TrackFailureFlightNotFound] 
                                          forKey:FlightLookupFailedReasonKey];
                            break;
                        case 410:
                            // Old flight
                            [reasonDict setValue:[NSNumber numberWithInt:TrackFailureOldFlight] 
                                          forKey:FlightLookupFailedReasonKey];
                            break;
                        default:
                            break;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FlightTrackFailedNotification 
                                                                        object:self
                                                                      userInfo:reasonDict];
                }
                else {
                    // TODO: Deal with no connection
                }
            }];
}

- (void)stopTracking {
    // TODO: Implement me
}


- (NSString *)description {
    // Primarily for debugging purposes so we can log/print Flights
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.actualArrivalTime ? self.actualArrivalTime : [NSNull null], 
                          @"actualArrivalTime",
                          self.actualDepartureTime ? self.actualDepartureTime : [NSNull null], 
                          @"actualDepartureTime",
                          self.destination ? [self.destination toDict] : [NSNull null], 
                          @"destination",
                          self.detailedStatus ? self.detailedStatus : [NSNull null],
                          @"detailedStatus",
                          self.estimatedArrivalTime ? self.estimatedArrivalTime : [NSNull null], 
                          @"estimatedArrivalTime",
                          self.flightID ? self.flightID : [NSNull null], 
                          @"flightID",
                          self.flightNumber ? self.flightNumber : [NSNull null],
                          @"flightNumber",
                          self.lastUpdated ? self.lastUpdated : [NSNull null],
                          @"lastUpdated",
                          self.leaveForAirporTime ? self.leaveForAirporTime : [NSNull null], 
                          @"leaveForAirportTime",
                          self.leaveForAirportRecommendation ? self.leaveForAirportRecommendation : [NSNull null], 
                          @"leaveForAirportRecommendation",
                          self.origin ? [self.origin toDict] : [NSNull null],
                          @"origin",
                          self.scheduledDepartureTime ? self.scheduledDepartureTime : [NSNull null],
                          @"scheduledDepartureTime",
                          [NSNumber numberWithDouble:self.scheduledFlightTime],
                          @"scheduledFlightTime",
                          [_statuses objectAtIndex:self.status],
                          @"status", nil];
    return [info description];
}


@end
