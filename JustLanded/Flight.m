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

NSString * const WillStopTrackingFlightNotification = @"WillStopTrackingFlightNotification";
NSString * const DidStopTrackingFlightNotification = @"DidStopTrackingFlightNotification";
NSString * const StopTrackingFlightFailedNotification = @"StopTrackingFlightFailedNotification";
NSString * const StopTrackingFailedReasonKey = @"StopTrackingFailedReasonKey";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface Flight () {
    __strong NSDate *_scheduledArrivalTime;
    __strong NSDate *_lastTracked;
}

+ (void)failToLookupWithReason:(FlightLookupFailedReason)reason;
- (void)updateWithFlightInfo:(NSDictionary *)info;
- (void)failToTrackWithReason:(FlightTrackFailedReason)reason;
- (NSDictionary *)flightData;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Flight

@synthesize flightID;
@synthesize flightNumber;
@synthesize aircraftType;
@synthesize timeOfDay;

@synthesize actualArrivalTime;
@synthesize actualDepartureTime;
@synthesize estimatedArrivalTime;
@synthesize scheduledDepartureTime;
@synthesize scheduledArrivalTime=_scheduledArrivalTime;
@synthesize lastUpdated;
@synthesize leaveForAirportTime;
@synthesize drivingTime;
@synthesize scheduledFlightDuration;

@synthesize origin;
@synthesize destination;

@synthesize status;
@synthesize detailedStatus;

@synthesize lastTracked=_lastTracked;

static NSArray *_statuses;
static NSArray *_pushTypes;
static NSArray *_aircraftTypes;

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
        _pushTypes = [[NSArray alloc] initWithObjects:@"FILED",
                      @"DIVERTED",
                      @"CANCELED",
                      @"DEPARTED",
                      @"ARRIVED",
                      @"CHANGED", 
                      @"LEAVE_SOON",
                      @"LEAVE_NOW", nil];
        _aircraftTypes = [[NSArray alloc] initWithObjects:@"JET2",
                      @"JET2REAR",
                      @"JET4",
                      @"PROP2",
                      @"PROP4", nil];
	}
}


+ (NSString *)aircraftTypeToString:(AircraftType)aType {
    return [_aircraftTypes objectAtIndex:aType];
}


+ (PushType)stringToPushType:(NSString *)typeString {
    NSUInteger index = [_pushTypes indexOfObject:typeString];
    if (index == NSNotFound) {
        return UnknownFlightAlert;
    }
    else {
        return index;
    }
}


- (id)initWithFlightInfo:(NSDictionary *)info {
    self = [super init];
    
    if (self) {
        [self updateWithFlightInfo:info];
    }
    return self;
}


- (void)updateWithFlightInfo:(NSDictionary *)info {
    // Process flight ID and number
    self.flightID = [info valueForKeyOrNil:@"flightID"];
    self.flightNumber = [info valueForKeyOrNil:@"flightNumber"];
    NSUInteger parsed_aircraft_type = [_aircraftTypes indexOfObject:[info valueForKeyOrNil:@"aircraftType"]];
    self.aircraftType = (parsed_aircraft_type == NSNotFound) ? PROP2 : parsed_aircraft_type;
    self.timeOfDay = ([[info valueForKey:@"isNight"] boolValue]) ? NIGHT : DAY;
    
    // Process and set all the flight date and time information
    self.actualArrivalTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"actualArrivalTime"] returnNilForZero:YES];
    self.actualDepartureTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"actualDepartureTime"] returnNilForZero:YES];
    self.estimatedArrivalTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"estimatedArrivalTime"] returnNilForZero:YES];
    self.scheduledDepartureTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"scheduledDepartureTime"] returnNilForZero:YES];
    self.lastUpdated = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"lastUpdated"] returnNilForZero:YES];
    self.leaveForAirportTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"leaveForAirportTime"] returnNilForZero:YES];
    // -1.0 means we have no driving time
    self.drivingTime = [info valueForKeyOrNil:@"drivingTime"] ? [[info valueForKeyOrNil:@"drivingTime"] doubleValue] : -1.0;
    self.scheduledFlightDuration = [[info valueForKeyOrNil:@"scheduledFlightDuration"] doubleValue];
    _scheduledArrivalTime = [NSDate dateWithTimeInterval:scheduledFlightDuration sinceDate:scheduledDepartureTime];
    
    // Process origin and destination
    self.origin = [[OriginAirport alloc] initWithAirportInfo:[info valueForKeyOrNil:@"origin"]];
    self.destination = [[DestinationAirport alloc] initWithAirportInfo:[info valueForKeyOrNil:@"destination"]];
    
    // Process status
    NSUInteger parsed_status = [_statuses indexOfObject:[info valueForKeyOrNil:@"status"]];
    self.status = (parsed_status == NSNotFound) ? UNKNOWN : parsed_status;
    self.detailedStatus = [info valueForKeyOrNil:@"detailedStatus"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flight Lookup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)lookupFlights:(NSString *)aFlightNumber {
    [[NSNotificationCenter defaultCenter] postNotificationName:WillLookupFlightNotification object:nil];
    
    NSString *lookupPath = [JustLandedAPIClient lookupPathWithFlightNumber:aFlightNumber];
    
    [[JustLandedAPIClient sharedClient] 
            getPath:lookupPath 
         parameters:nil 
            success:^(AFHTTPRequestOperation *operation, id JSON){                
                if (JSON && [JSON isKindOfClass:[NSArray class]]) {
                    // Got the flight data, return a list of flights
                    NSDictionary *flights = nil;
                    
                    @try {
                        NSArray *listOfFlightInfo = (NSArray *)JSON;
                        NSMutableArray *listOfFlights = [[NSMutableArray alloc] init];
                        for (NSDictionary *info in listOfFlightInfo) {
                            [listOfFlights addObject:[[Flight alloc] initWithFlightInfo:info]];
                        }
                        
                        flights = [NSDictionary dictionaryWithObjectsAndKeys:listOfFlights, @"flights", nil];
                    }
                    @catch (NSException *exception) {
                        [self failToLookupWithReason:LookupFailureError];
                        [FlurryAnalytics logEvent:FY_BAD_DATA];
                        return;
                    }
                    
                    // Post success notification with fetched flights attached
                    [[NSNotificationCenter defaultCenter] postNotificationName:DidLookupFlightNotification 
                                                                        object:nil
                                                                      userInfo:flights];
                }

            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {                
                NSHTTPURLResponse *response = [operation response];
                if (response) {
                    switch ([response statusCode]) {
                        case 400:
                            // Invalid flight number
                            [self failToLookupWithReason:LookupFailureInvalidFlightNumber];
                            [FlurryAnalytics logEvent:FY_INVALID_FLIGHT_NUM_ERROR];
                            break;
                        case 404:
                            // Flight not found
                            [self failToLookupWithReason:LookupFailureFlightNotFound];
                            [FlurryAnalytics logEvent:FY_FLIGHT_NOT_FOUND_ERROR];
                            break;
                        default:
                            // 500 errors etc.
                            [self failToLookupWithReason:LookupFailureError];
                            [FlurryAnalytics logEvent:FY_SERVER_500];
                            break;
                    }
                }
                else {
                    // Handle connection problem
                    [self failToLookupWithReason:LookupFailureNoConnection];
                    [FlurryAnalytics logEvent:FY_NO_CONNECTION_ERROR];
                }
            }];
}


+ (void)failToLookupWithReason:(FlightLookupFailedReason)reason {
    NSDictionary *reasonDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:reason] 
                                                           forKey:FlightLookupFailedReasonKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FlightLookupFailedNotification 
                                                        object:nil 
                                                      userInfo:reasonDict];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flight Tracking
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)trackWithLocation:(CLLocation *)loc pushEnabled:(BOOL)pushFlag {
    [[NSNotificationCenter defaultCenter] postNotificationName:WillTrackFlightNotification object:self];
    
    NSString *trackingPath = [JustLandedAPIClient trackPathWithFlightNumber:flightNumber flightID:flightID];
    NSMutableDictionary *trackingParams = [[NSMutableDictionary alloc] init];
    
    if (loc) {
        [trackingParams setValue:[NSNumber numberWithFloat:loc.coordinate.latitude] forKey:@"latitude"];
        [trackingParams setValue:[NSNumber numberWithFloat:loc.coordinate.longitude] forKey:@"longitude"];
    }
    
    if (pushFlag) {
        [trackingParams setValue:[[JustLandedSession sharedSession] pushToken] forKey:@"push_token"];
    }
    
    [[JustLandedAPIClient sharedClient] 
            getPath:trackingPath 
         parameters:trackingParams 
            success:^(AFHTTPRequestOperation *operation, id JSON){
                if (JSON && [JSON isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *prevData = [self flightData];
                    NSDictionary *flightInfo = (NSDictionary *)JSON;
                    @try {
                        [self updateWithFlightInfo:flightInfo];
                    }
                    @catch (NSException *exception) {
                        // Problem updating the data
                        [self failToTrackWithReason:TrackFailureError];
                        [FlurryAnalytics logEvent:FY_BAD_DATA];
                        
                        // Restore the old data
                        [self updateWithFlightInfo:prevData];
                        return;
                    }
                    
                    _lastTracked = [NSDate date];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DidTrackFlightNotification object:self];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSHTTPURLResponse *response = [operation response];
                
                if (response) {
                    switch ([response statusCode]) {
                        case 400:
                            // Invalid flight number
                            [self failToTrackWithReason:TrackFailureInvalidFlightNumber];
                            [FlurryAnalytics logEvent:FY_INVALID_FLIGHT_NUM_ERROR];
                            break;
                        case 404:
                            // Flight not found
                            [self failToTrackWithReason:TrackFailureFlightNotFound];
                            [FlurryAnalytics logEvent:FY_FLIGHT_NOT_FOUND_ERROR];
                            break;
                        case 410:
                            // Old flight
                            [self failToTrackWithReason:TrackFailureOldFlight];
                            [FlurryAnalytics logEvent:FY_OLD_FLIGHT_ERROR];
                            break;
                        default:
                            // 500 errors etc.
                            [self failToTrackWithReason:TrackFailureError];
                            [FlurryAnalytics logEvent:FY_SERVER_500];
                            break;
                    }
                }
                else {
                    // Deal with no connection
                    [self failToTrackWithReason:TrackFailureNoConnection];
                    [FlurryAnalytics logEvent:FY_NO_CONNECTION_ERROR];
                }
            }];
}


- (void)failToTrackWithReason:(FlightTrackFailedReason)reason {
    NSDictionary *reasonDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:reason] 
                                                           forKey:FlightTrackFailedReasonKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FlightTrackFailedNotification 
                                                        object:self 
                                                      userInfo:reasonDict];
}


- (void)stopTracking {
    [[NSNotificationCenter defaultCenter] postNotificationName:WillStopTrackingFlightNotification object:self];
    
    NSString *stopTrackingPath = [JustLandedAPIClient stopTrackingPathWithFlightID:flightID];
    
    [[JustLandedAPIClient sharedClient] 
     getPath:stopTrackingPath 
     parameters:nil 
     success:^(AFHTTPRequestOperation *operation, id JSON) {
         [[NSNotificationCenter defaultCenter] postNotificationName:DidStopTrackingFlightNotification object:self];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[NSNotificationCenter defaultCenter] postNotificationName:StopTrackingFlightFailedNotification object:self];
     }];
}


- (NSUInteger)minutesBeforeLanding {
    if (self.status == LANDED) {
        return 0;
    } 
    else {
        if (self.estimatedArrivalTime) {
            NSTimeInterval timeToLanding = [self.estimatedArrivalTime timeIntervalSinceNow];
            return (NSUInteger) abs(round(timeToLanding / 60.0));
        }
        else if (self.scheduledArrivalTime) {
            NSTimeInterval timeToLanding = [self.scheduledArrivalTime timeIntervalSinceNow];
            return (NSUInteger) abs(round(timeToLanding / 60.0));
        }
        else {
            return 0; // Shouldn't happen
        }
    }
}


- (CGFloat)currentProgress {
    if (self.status == LANDED) {
        return 1.0f;
    }
    else if (!actualDepartureTime) {
        return 0.0f;
    }
    else {
        NSTimeInterval totalFlightTime = [estimatedArrivalTime timeIntervalSinceDate:actualDepartureTime];
        NSTimeInterval timeSinceTakeoff = [[NSDate date] timeIntervalSinceDate:actualDepartureTime];
        
        if (timeSinceTakeoff > totalFlightTime) {
            return 0.9999f; // Delay before reporting landed
        }
        else {
            return (float) timeSinceTakeoff / totalFlightTime; // Return the fraction of the flight completed
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Conforming to NSCoding
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        // For each instance variable that is archived, we decode it
        self.flightID = [aDecoder decodeObjectForKey:@"flightID"];
        self.flightNumber = [aDecoder decodeObjectForKey:@"flightNumber"];
        self.aircraftType = [aDecoder decodeIntegerForKey:@"aircraftType"];
        self.timeOfDay = [aDecoder decodeIntegerForKey:@"timeOfDay"];
        
        self.actualArrivalTime = [aDecoder decodeObjectForKey:@"actualArrivalTime"];
        self.actualDepartureTime = [aDecoder decodeObjectForKey:@"actualDepartureTime"];
        self.estimatedArrivalTime = [aDecoder decodeObjectForKey:@"estimatedArrivalTime"];
        self.scheduledDepartureTime = [aDecoder decodeObjectForKey:@"scheduledDepartureTime"];
        _scheduledArrivalTime = [aDecoder decodeObjectForKey:@"scheduledArrivalTime"];
        self.lastUpdated = [aDecoder decodeObjectForKey:@"lastUpdated"];
        self.leaveForAirportTime = [aDecoder decodeObjectForKey:@"leaveForAirportTime"];
        self.drivingTime = [aDecoder decodeDoubleForKey:@"drivingTime"];
        self.scheduledFlightDuration = [aDecoder decodeDoubleForKey:@"scheduledFlightDuration"];
        
        self.origin = [aDecoder decodeObjectForKey:@"origin"];
        self.destination = [aDecoder decodeObjectForKey:@"destination"];
        
        self.status = [aDecoder decodeIntegerForKey:@"status"];
        self.detailedStatus = [aDecoder decodeObjectForKey:@"detailedStatus"];
        
        _lastTracked = [aDecoder decodeObjectForKey:@"_lastTracked"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Archive each instance variable under its variable name
    [aCoder encodeObject:flightID forKey:@"flightID"];
    [aCoder encodeObject:flightNumber forKey:@"flightNumber"];
    [aCoder encodeInteger:aircraftType forKey:@"aircraftType"];
    [aCoder encodeInteger:timeOfDay forKey:@"timeOfDay"];
    
    [aCoder encodeObject:actualArrivalTime forKey:@"actualArrivalTime"];
    [aCoder encodeObject:actualDepartureTime forKey:@"actualDepartureTime"];
    [aCoder encodeObject:estimatedArrivalTime forKey:@"estimatedArrivalTime"];
    [aCoder encodeObject:scheduledDepartureTime forKey:@"scheduledDepartureTime"];
    [aCoder encodeObject:_scheduledArrivalTime forKey:@"scheduledArrivalTime"];
    [aCoder encodeObject:lastUpdated forKey:@"lastUpdated"];
    [aCoder encodeObject:leaveForAirportTime forKey:@"leaveForAirportTime"];
    [aCoder encodeDouble:drivingTime forKey:@"drivingTime"];
    [aCoder encodeDouble:scheduledFlightDuration forKey:@"scheduledFlightDuration"];
    
    [aCoder encodeObject:origin forKey:@"origin"];
    [aCoder encodeObject:destination forKey:@"destination"];
    
    [aCoder encodeInteger:status forKey:@"status"];
    [aCoder encodeObject:detailedStatus forKey:@"detailedStatus"];
    
    [aCoder encodeObject:_lastTracked forKey:@"_lastTracked"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isEqual:(id)object {
    // Want to be able to test equality of Flights by their data - they must match on all properties
    
    if ([object isKindOfClass:[self class]]) {
        Flight *aFlight = (Flight *)object;
        return ([flightID isEqualToString:aFlight.flightID] &&
                [flightNumber isEqualToString:aFlight.flightNumber] &&
                aircraftType == aFlight.aircraftType &&
                timeOfDay == aFlight.timeOfDay &&
                
                [actualArrivalTime isEqualToDate:aFlight.actualArrivalTime] &&
                [actualDepartureTime isEqualToDate:aFlight.actualDepartureTime] &&
                [estimatedArrivalTime isEqualToDate:aFlight.estimatedArrivalTime] &&
                [scheduledDepartureTime isEqualToDate:aFlight.scheduledDepartureTime] &&
                [_scheduledArrivalTime isEqualToDate:aFlight.scheduledArrivalTime] &&
                [lastUpdated isEqualToDate:aFlight.lastUpdated] &&
                [leaveForAirportTime isEqualToDate:aFlight.leaveForAirportTime] &&
                drivingTime == aFlight.drivingTime &&
                scheduledFlightDuration == aFlight.scheduledFlightDuration &&
                
                [origin isEqual:aFlight.origin] &&
                [destination isEqual:aFlight.destination] &&
                
                status == aFlight.status &&
                [detailedStatus isEqualToString:aFlight.detailedStatus] &&
                
                [_lastTracked isEqualToDate:aFlight.lastTracked]);
    }
    else {
        return NO;
    }
}


- (NSDictionary *)flightData {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            flightID ? flightID : [NSNull null], @"flightID",
            flightNumber ? flightNumber : [NSNull null], @"flightNumber",
            [_aircraftTypes objectAtIndex:aircraftType], @"aircraftType",
            
            actualArrivalTime ? [actualArrivalTime description] : [NSNull null], @"actualArrivalTime",
            actualDepartureTime ? [actualDepartureTime description] : [NSNull null], @"actualDepartureTime",
            estimatedArrivalTime ? [estimatedArrivalTime description] : [NSNull null], @"estimatedArrivalTime",
            scheduledDepartureTime ? [scheduledDepartureTime description] : [NSNull null], @"scheduledDepartureTime",
            lastUpdated ? [lastUpdated description] : [NSNull null], @"lastUpdated",
            leaveForAirportTime ? [leaveForAirportTime description] : [NSNull null], @"leaveForAirportTime",
            drivingTime >= 0.0 ? [NSNumber numberWithDouble:drivingTime] : [NSNull null], @"drivingTime",
            [NSNumber numberWithDouble:scheduledFlightDuration], @"scheduledFlightDuration",
            
            origin ? [origin toJSONFriendlyDict] : [NSNull null], @"origin",
            destination ? [destination toJSONFriendlyDict] : [NSNull null], @"destination",
            
            [_statuses objectAtIndex:status], @"status",
            detailedStatus ? detailedStatus : [NSNull null], @"detailedStatus", nil];
}


- (NSString *)flightDataAsJson {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self flightData]
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:&error];
    if (error) {
        return nil;
    }
    else {
        return [NSString stringWithUTF8String:[jsonData bytes]]; 
    }
}


- (NSString *)description {
    // Be able to nicely print a flight with only the information sent by the server
    return [[self flightData] description];
}

@end
