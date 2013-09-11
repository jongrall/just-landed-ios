//
//  Flight.m
//  Just Landed
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
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

@interface Flight ()

// Redefine as readwrite
@property (strong, readwrite, nonatomic) NSDate *scheduledArrivalTime;
@property (strong, readwrite, nonatomic) NSDate *lastTracked;

+ (void)failToLookupWithReason:(FlightLookupFailedReason)aFailureReason;
- (void)updateWithFlightInfo:(NSDictionary *)someFlightInfo;
- (void)failToTrackWithReason:(FlightTrackFailedReason)aFailureReason;
- (NSDictionary *)flightData;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Flight

@synthesize flightID = flightID_;
@synthesize flightNumber = flightNumber_;
@synthesize aircraftType = aircraftType_;
@synthesize timeOfDay = timeOfDay_;
@synthesize actualArrivalTime = actualArrivalTime_;
@synthesize actualDepartureTime = actualDepartureTime_;
@synthesize estimatedArrivalTime = estimatedArrivalTime_;
@synthesize scheduledDepartureTime = scheduledDepartureTime_;
@synthesize lastUpdated = lastUpdated_;
@synthesize leaveForAirportTime = leaveForAirportTime_;
@synthesize drivingTime = drivingTime_;
@synthesize scheduledFlightDuration = scheduledFlightDuration_;
@synthesize scheduledArrivalTime = scheduledArrivalTime_;
@synthesize origin = origin_;
@synthesize destination = destination_;
@synthesize status = status_;
@synthesize detailedStatus = detailedStatus_;

static NSArray *sStatuses_;
static NSArray *sPushTypes_;
static NSArray *sAircraftTypes_;

+ (void)initialize {
	if (self == [Flight class]) {
        sStatuses_ = @[@"SCHEDULED",
                     @"ON_TIME",
                     @"DELAYED",
                     @"CANCELED",
                     @"DIVERTED",
                     @"LANDED",
                     @"EARLY",
                     @"UNKNOWN"];
        sPushTypes_ = @[@"FILED",
                      @"DIVERTED",
                      @"CANCELED",
                      @"DEPARTED",
                      @"ARRIVED",
                      @"CHANGED", 
                      @"LEAVE_SOON",
                      @"LEAVE_NOW"];
        sAircraftTypes_ = @[@"JET2",
                      @"JET2REAR",
                      @"JET4",
                      @"PROP2",
                      @"PROP4"];
	}
}


+ (NSString *)aircraftTypeToString:(AircraftType)anAircraftType {
    return sAircraftTypes_[anAircraftType];
}


+ (PushType)stringToPushType:(NSString *)aPushTypeString {
    NSUInteger index = [sPushTypes_ indexOfObject:aPushTypeString];
    if (index == NSNotFound) {
        return UnknownFlightAlert;
    }
    else {
        return index;
    }
}


- (id)initWithFlightInfo:(NSDictionary *)someFlightInfo {
    self = [super init];
    
    if (self) {
        // Process flight ID and number
        flightID_ = [someFlightInfo valueForKeyOrNil:@"flightID"];
        flightNumber_ = [someFlightInfo valueForKeyOrNil:@"flightNumber"];
        NSUInteger parsed_aircraft_type = [sAircraftTypes_ indexOfObject:[someFlightInfo valueForKeyOrNil:@"aircraftType"]];
        aircraftType_ = (parsed_aircraft_type == NSNotFound) ? JET2 : parsed_aircraft_type;
        timeOfDay_ = ([[someFlightInfo valueForKey:@"isNight"] boolValue]) ? NIGHT : DAY;
        
        // Process and set all the flight date and time information
        actualArrivalTime_ = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"actualArrivalTime"] returnNilForZero:YES];
        actualDepartureTime_ = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"actualDepartureTime"] returnNilForZero:YES];
        estimatedArrivalTime_ = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"estimatedArrivalTime"] returnNilForZero:YES];
        scheduledDepartureTime_ = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"scheduledDepartureTime"] returnNilForZero:YES];
        lastUpdated_ = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"lastUpdated"] returnNilForZero:YES];
        leaveForAirportTime_ = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"leaveForAirportTime"] returnNilForZero:YES];
        drivingTime_ = [someFlightInfo valueForKeyOrNil:@"drivingTime"] ? [[someFlightInfo valueForKeyOrNil:@"drivingTime"] doubleValue] : -1.0; // -1.0 means we have no driving time
        scheduledFlightDuration_ = [[someFlightInfo valueForKeyOrNil:@"scheduledFlightDuration"] doubleValue];
        scheduledArrivalTime_ = [NSDate dateWithTimeInterval:scheduledFlightDuration_ sinceDate:scheduledDepartureTime_];
        
        // Process origin and destination
        origin_ = [[OriginAirport alloc] initWithAirportInfo:[someFlightInfo valueForKeyOrNil:@"origin"]];
        destination_ = [[DestinationAirport alloc] initWithAirportInfo:[someFlightInfo valueForKeyOrNil:@"destination"]];
        
        // Process status
        NSUInteger parsed_status = [sStatuses_ indexOfObject:[someFlightInfo valueForKeyOrNil:@"status"]];
        status_ = (parsed_status == NSNotFound) ? UNKNOWN : parsed_status;
        detailedStatus_ = [someFlightInfo valueForKeyOrNil:@"detailedStatus"];
    }
    return self;
}


- (void)updateWithFlightInfo:(NSDictionary *)someFlightInfo {
    // Process flight ID and number
    self.flightID = [someFlightInfo valueForKeyOrNil:@"flightID"];
    self.flightNumber = [someFlightInfo valueForKeyOrNil:@"flightNumber"];
    NSUInteger parsed_aircraft_type = [sAircraftTypes_ indexOfObject:[someFlightInfo valueForKeyOrNil:@"aircraftType"]];
    self.aircraftType = (parsed_aircraft_type == NSNotFound) ? JET2 : parsed_aircraft_type;
    self.timeOfDay = ([[someFlightInfo valueForKey:@"isNight"] boolValue]) ? NIGHT : DAY;
    
    // Process and set all the flight date and time information
    self.actualArrivalTime = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"actualArrivalTime"] returnNilForZero:YES];
    self.actualDepartureTime = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"actualDepartureTime"] returnNilForZero:YES];
    self.estimatedArrivalTime = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"estimatedArrivalTime"] returnNilForZero:YES];
    self.scheduledDepartureTime = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"scheduledDepartureTime"] returnNilForZero:YES];
    self.lastUpdated = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"lastUpdated"] returnNilForZero:YES];
    self.leaveForAirportTime = [NSDate dateWithTimestamp:[someFlightInfo valueForKeyOrNil:@"leaveForAirportTime"] returnNilForZero:YES];
    self.drivingTime = [someFlightInfo valueForKeyOrNil:@"drivingTime"] ? [[someFlightInfo valueForKeyOrNil:@"drivingTime"] doubleValue] : -1.0; // -1.0 means we have no driving time
    self.scheduledFlightDuration = [[someFlightInfo valueForKeyOrNil:@"scheduledFlightDuration"] doubleValue];
    self.scheduledArrivalTime = [NSDate dateWithTimeInterval:self.scheduledFlightDuration sinceDate:self.scheduledDepartureTime];
    
    // Process origin and destination
    self.origin = [[OriginAirport alloc] initWithAirportInfo:[someFlightInfo valueForKeyOrNil:@"origin"]];
    self.destination = [[DestinationAirport alloc] initWithAirportInfo:[someFlightInfo valueForKeyOrNil:@"destination"]];
    
    // Process status
    NSUInteger parsed_status = [sStatuses_ indexOfObject:[someFlightInfo valueForKeyOrNil:@"status"]];
    self.status = (parsed_status == NSNotFound) ? UNKNOWN : parsed_status;
    self.detailedStatus = [someFlightInfo valueForKeyOrNil:@"detailedStatus"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flight Lookup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)lookupFlights:(NSString *)aFlightNumber {
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:WillLookupFlightNotification object:nil];

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
                        
                        flights = @{@"flights": listOfFlights};
                    }
                    @catch (NSException *exception) {
                        [self failToLookupWithReason:LookupFailureError];
                        [Flurry logEvent:FY_BAD_DATA];
                        return;
                    }
                    
                    // Post success notification with fetched flights attached
                    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:DidLookupFlightNotification 
                                                                                    object:nil
                                                                                  userInfo:flights];
                }

            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {                
                NSHTTPURLResponse *response = [operation response];
                if (response) {
                    switch ([response statusCode]) {
                        case 400: {
                            // Invalid flight number
                            [self failToLookupWithReason:LookupFailureInvalidFlightNumber];
                            [Flurry logEvent:FY_INVALID_FLIGHT_NUM_ERROR];
                            break;
                        }
                        case 404: {
                            // Flight not found or no current flight found
                            BOOL noCurrentFlight = NO;
                            
                            // Figure out if this is a situation where we have no current flight matching vs. no flight at all
                            if ([operation isKindOfClass:[AFJSONRequestOperation class]] && [(AFJSONRequestOperation *)operation responseJSON]) {
                                id responseJSON = [(AFJSONRequestOperation *)operation responseJSON];
                                if ([responseJSON isKindOfClass:[NSDictionary class]]) {
                                    NSDictionary *errorResponse = (NSDictionary *)responseJSON;
                                    NSString *errorMsg = [errorResponse valueForKeyOrNil:@"error"];
                                    if ([errorMsg isKindOfClass:[NSString class]]) {
                                        noCurrentFlight = [errorMsg hasPrefix:@"No recent"];
                                    }
                                }
                            }
                            
                            if (noCurrentFlight) {
                                [self failToLookupWithReason:LookupFailureNoCurrentFlight];
                                [Flurry logEvent:FY_CURRENT_FLIGHT_NOT_FOUND_ERROR];
                            }
                            else {
                                [self failToLookupWithReason:LookupFailureFlightNotFound];
                                [Flurry logEvent:FY_FLIGHT_NOT_FOUND_ERROR];
                            }
                            break;
                        }
                        case 503: {
                            //Outage
                            [self failToLookupWithReason:LookupFailureOutage];
                            [Flurry logEvent:FY_OUTAGE];
                            break;
                        }
                        default: {
                            // 500 errors etc.
                            [self failToLookupWithReason:LookupFailureError];
                            [Flurry logEvent:FY_SERVER_500];
                            break;
                        }
                    }
                }
                else {
                    // Handle possible connection problem / server not responding
                    if ([[JustLandedSession sharedSession] isJustLandedReachable]) {
                        // JL is reachable, there must be a server outage
                        [self failToLookupWithReason:LookupFailureOutage];
                        [Flurry logEvent:FY_OUTAGE];
                    }
                    else {
                        // JL is not reachable, they have no connection
                        [self failToLookupWithReason:LookupFailureNoConnection];
                        [Flurry logEvent:FY_NO_CONNECTION_ERROR];
                    }
                }
            }];
}


+ (void)failToLookupWithReason:(FlightLookupFailedReason)aFailureReason {
    NSDictionary *reasonDict = @{FlightLookupFailedReasonKey: [NSNumber numberWithInt:aFailureReason]};
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:FlightLookupFailedNotification 
                                                                    object:nil 
                                                                  userInfo:reasonDict];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flight Tracking
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)trackWithLocation:(CLLocation *)aLocation pushToken:(NSString *)aPushToken {
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:WillTrackFlightNotification object:self];
    NSString *trackingPath = [JustLandedAPIClient trackPathWithFlightNumber:self.flightNumber flightID:self.flightID];
    NSMutableDictionary *trackingParams = [[JustLandedSession sharedSession] currentTrackingPreferences];
    
    if (aLocation) {
        [trackingParams setValue:[NSNumber numberWithDouble:aLocation.coordinate.latitude] forKey:@"latitude"];
        [trackingParams setValue:[NSNumber numberWithDouble:aLocation.coordinate.longitude] forKey:@"longitude"];
    }
    
    if (aPushToken) {
        [trackingParams setValue:aPushToken forKey:@"push_token"];
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
                        [Flurry logEvent:FY_BAD_DATA];
                        
                        // Restore the old data
                        [self updateWithFlightInfo:prevData];
                        return;
                    }
                    
                    self.lastTracked = [NSDate date];
                    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:DidTrackFlightNotification object:self];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {                
                NSHTTPURLResponse *response = [operation response];
                
                if (response) {
                    switch ([response statusCode]) {
                        case 400: {
                            // Invalid flight number
                            [self failToTrackWithReason:TrackFailureInvalidFlightNumber];
                            [Flurry logEvent:FY_INVALID_FLIGHT_NUM_ERROR];
                            break;
                        }
                        case 404: {
                            // Flight not found
                            [self failToTrackWithReason:TrackFailureFlightNotFound];
                            [Flurry logEvent:FY_FLIGHT_NOT_FOUND_ERROR];
                            break;
                        }
                        case 410: {
                            // Old flight
                            [self failToTrackWithReason:TrackFailureOldFlight];
                            [Flurry logEvent:FY_OLD_FLIGHT_ERROR];
                            break;
                        }
                        case 503: {
                            // Outage
                            [self failToTrackWithReason:TrackFailureOutage];
                            [Flurry logEvent:FY_OUTAGE];
                            break;
                        }
                        default: {
                            // 500 errors etc.
                            [self failToTrackWithReason:TrackFailureError];
                            [Flurry logEvent:FY_SERVER_500];
                            break;
                        }
                    }
                }
                else {
                    // Handle possible connection problem / server not responding
                    if ([[JustLandedSession sharedSession] isJustLandedReachable]) {
                        // JL is reachable, there must be a server outage
                        [self failToTrackWithReason:TrackFailureOutage];
                        [Flurry logEvent:FY_OUTAGE];
                    }
                    else {
                        // JL is not reachable, they have no connection
                        [self failToTrackWithReason:TrackFailureNoConnection];
                        [Flurry logEvent:FY_NO_CONNECTION_ERROR];
                    }
                }
            }];
}


- (void)failToTrackWithReason:(FlightTrackFailedReason)aFailureReason {
    NSDictionary *reasonDict = @{FlightTrackFailedReasonKey: [NSNumber numberWithInt:aFailureReason]};
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:FlightTrackFailedNotification 
                                                                    object:self 
                                                                  userInfo:reasonDict];
}


- (void)stopTracking {
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:WillStopTrackingFlightNotification object:self];
    
    NSString *stopTrackingPath = [JustLandedAPIClient stopTrackingPathWithFlightID:self.flightID];
    
    [[JustLandedAPIClient sharedClient] 
     getPath:stopTrackingPath 
     parameters:nil 
     success:^(AFHTTPRequestOperation *operation, id JSON) {
         [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:DidStopTrackingFlightNotification object:self];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:StopTrackingFlightFailedNotification object:self];
     }];
}


- (NSUInteger)minutesBeforeLanding {
    if (self.status == LANDED) {
        return 0;
    } 
    else {
        if (self.estimatedArrivalTime) {
            NSTimeInterval timeToLanding = [self.estimatedArrivalTime timeIntervalSinceNow];
            return (NSUInteger) fabs(round(timeToLanding / 60.0));
        }
        else if (self.scheduledArrivalTime) {
            NSTimeInterval timeToLanding = [self.scheduledArrivalTime timeIntervalSinceNow];
            return (NSUInteger) fabs(round(timeToLanding / 60.0));
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
    else if (!self.actualDepartureTime) {
        return 0.0f;
    }
    else {
        NSTimeInterval totalFlightTime = [self.estimatedArrivalTime timeIntervalSinceDate:self.actualDepartureTime];
        NSTimeInterval timeSinceTakeoff = [[NSDate date] timeIntervalSinceDate:self.actualDepartureTime];
        
        if (timeSinceTakeoff > totalFlightTime) {
            return 0.9999f; // Delay before reporting landed
        }
        else {
            return (CGFloat) (timeSinceTakeoff / totalFlightTime); // Return the fraction of the flight completed
        }
    }
}


- (BOOL)isDataFresh {
    return self.lastTracked != nil && ([[NSDate date] timeIntervalSinceDate:self.lastTracked] < TRACK_FRESHNESS_THRESHOLD);
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
        self.scheduledArrivalTime = [aDecoder decodeObjectForKey:@"scheduledArrivalTime"];
        self.lastUpdated = [aDecoder decodeObjectForKey:@"lastUpdated"];
        self.leaveForAirportTime = [aDecoder decodeObjectForKey:@"leaveForAirportTime"];
        self.drivingTime = [aDecoder decodeDoubleForKey:@"drivingTime"];
        self.scheduledFlightDuration = [aDecoder decodeDoubleForKey:@"scheduledFlightDuration"];
        
        self.origin = [aDecoder decodeObjectForKey:@"origin"];
        self.destination = [aDecoder decodeObjectForKey:@"destination"];
        
        self.status = [aDecoder decodeIntegerForKey:@"status"];
        self.detailedStatus = [aDecoder decodeObjectForKey:@"detailedStatus"];
        
        self.lastTracked = [aDecoder decodeObjectForKey:@"_lastTracked"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Archive each instance variable under its variable name
    [aCoder encodeObject:self.flightID forKey:@"flightID"];
    [aCoder encodeObject:self.flightNumber forKey:@"flightNumber"];
    [aCoder encodeInteger:self.aircraftType forKey:@"aircraftType"];
    [aCoder encodeInteger:self.timeOfDay forKey:@"timeOfDay"];
    
    [aCoder encodeObject:self.actualArrivalTime forKey:@"actualArrivalTime"];
    [aCoder encodeObject:self.actualDepartureTime forKey:@"actualDepartureTime"];
    [aCoder encodeObject:self.estimatedArrivalTime forKey:@"estimatedArrivalTime"];
    [aCoder encodeObject:self.scheduledDepartureTime forKey:@"scheduledDepartureTime"];
    [aCoder encodeObject:self.scheduledArrivalTime forKey:@"scheduledArrivalTime"];
    [aCoder encodeObject:self.lastUpdated forKey:@"lastUpdated"];
    [aCoder encodeObject:self.leaveForAirportTime forKey:@"leaveForAirportTime"];
    [aCoder encodeDouble:self.drivingTime forKey:@"drivingTime"];
    [aCoder encodeDouble:self.scheduledFlightDuration forKey:@"scheduledFlightDuration"];
    
    [aCoder encodeObject:self.origin forKey:@"origin"];
    [aCoder encodeObject:self.destination forKey:@"destination"];
    
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeObject:self.detailedStatus forKey:@"detailedStatus"];
    
    [aCoder encodeObject:self.lastTracked forKey:@"_lastTracked"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isEqual:(id)object {
    // Want to be able to test equality of Flights by their flightID (data may be different depending on when it was fetched)
    
    if ([object isKindOfClass:[self class]]) {
        Flight *aFlight = (Flight *)object;
        return [self.flightID isEqualToString:aFlight.flightID];
    }
    else {
        return NO;
    }
}


- (NSDictionary *)flightData {
    return @{@"flightID": self.flightID ? self.flightID : [NSNull null],
            @"flightNumber": self.flightNumber ? self.flightNumber : [NSNull null],
            @"aircraftType": sAircraftTypes_[self.aircraftType],
            
            @"actualArrivalTime": self.actualArrivalTime ? [self.actualArrivalTime description] : [NSNull null],
            @"actualDepartureTime": self.actualDepartureTime ? [self.actualDepartureTime description] : [NSNull null],
            @"estimatedArrivalTime": self.estimatedArrivalTime ? [self.estimatedArrivalTime description] : [NSNull null],
            @"scheduledDepartureTime": self.scheduledDepartureTime ? [self.scheduledDepartureTime description] : [NSNull null],
            @"lastUpdated": self.lastUpdated ? [self.lastUpdated description] : [NSNull null],
            @"leaveForAirportTime": self.leaveForAirportTime ? [self.leaveForAirportTime description] : [NSNull null],
            @"drivingTime": self.drivingTime >= 0.0 ? @(self.drivingTime) : [NSNull null],
            @"scheduledFlightDuration": @(self.scheduledFlightDuration),
            
            @"origin": self.origin ? [self.origin toJSONFriendlyDict] : [NSNull null],
            @"destination": self.destination ? [self.destination toJSONFriendlyDict] : [NSNull null],
            
            @"status": sStatuses_[self.status],
            @"detailedStatus": self.detailedStatus ? self.detailedStatus : [NSNull null]};
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
