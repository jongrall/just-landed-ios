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
- (BOOL)hasDeliveredAlertType:(LeaveForAirportReminderType)type;
- (void)scheduleAlert:(UILocalNotification *)newAlert;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Flight

@synthesize flightID;
@synthesize flightNumber;

@synthesize actualArrivalTime;
@synthesize actualDepartureTime;
@synthesize estimatedArrivalTime;
@synthesize scheduledDepartureTime;
@synthesize scheduledArrivalTime=_scheduledArrivalTime;
@synthesize lastUpdated;
@synthesize leaveForAirporTime;
@synthesize scheduledFlightDuration;

@synthesize origin;
@synthesize destination;

@synthesize status;
@synthesize detailedStatus;

@synthesize lastTracked=_lastTracked;
@synthesize scheduledAlerts;

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


- (id)initWithFlightInfo:(NSDictionary *)info {
    self = [super init];
    
    if (self) {
        self.scheduledAlerts = [[NSMutableArray alloc] init];
        [self updateWithFlightInfo:info];
    }
    return self;
}


- (void)updateWithFlightInfo:(NSDictionary *)info {
    // Process flight ID and number
    self.flightID = [info valueForKeyOrNil:@"flightID"];
    self.flightNumber = [info valueForKeyOrNil:@"flightNumber"];
    
    // Process and set all the flight date and time information
    self.actualArrivalTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"actualArrivalTime"] returnNilForZero:YES];
    self.actualDepartureTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"actualDepartureTime"] returnNilForZero:YES];
    self.estimatedArrivalTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"estimatedArrivalTime"] returnNilForZero:YES];
    self.scheduledDepartureTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"scheduledDepartureTime"] returnNilForZero:YES];
    self.lastUpdated = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"lastUpdated"] returnNilForZero:YES];
    self.leaveForAirporTime = [NSDate dateWithTimestamp:[info valueForKeyOrNil:@"leaveForAirportTime"] returnNilForZero:YES];
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
                if (response) {
                    switch ([response statusCode]) {
                        case 400:
                            // Invalid flight number
                            [self failToLookupWithReason:LookupFailureInvalidFlightNumber];
                            break;
                        case 404:
                            // Flight not found
                            [self failToLookupWithReason:LookupFailureFlightNotFound];
                            break;
                        default:
                            // 500 errors etc.
                            [self failToLookupWithReason:LookupFailureError];
                            break;
                    }
                }
                else {
                    // Handle connection problem
                    [self failToLookupWithReason:LookupFailureNoConnection];
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
                    NSDictionary *flightInfo = (NSDictionary *)JSON;
                    [self updateWithFlightInfo:flightInfo];
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
                            break;
                        case 404:
                            // Flight not found
                            [self failToTrackWithReason:TrackFailureFlightNotFound];
                            break;
                        case 410:
                            // Old flight
                            [self failToTrackWithReason:TrackFailureOldFlight];
                            break;
                        default:
                            // 500 errors etc.
                            [self failToTrackWithReason:TrackFailureError];
                            break;
                    }
                }
                else {
                    // Deal with no connection
                    [self failToTrackWithReason:TrackFailureNoConnection];
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
         // TODO: Implement me
         [[NSNotificationCenter defaultCenter] postNotificationName:DidStopTrackingFlightNotification object:self];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         // TODO: Implement me
         [[NSNotificationCenter defaultCenter] postNotificationName:StopTrackingFlightFailedNotification object:self];
     }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Leave Alerts
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)createOrUpdateLeaveAlerts {
    // Only create or update if we have an estimate of when to leave. In the case that we couldn't get their location,
    // we want any existing alerts for this flight to remain as a fallback if we were able to get their location earlier.
    if (leaveForAirporTime) {
        
        // Cancel any existing leave alerts for this flight
        [self cancelLeaveAlerts];
        
        // Try to give the airport name, if we can't fallback to IATA code and then ICAO code
        NSString *airportNameOrCode = (self.destination.name) ? self.destination.name :
        ((self.destination.iataCode) ? self.destination.iataCode :
         self.destination.icaoCode);
        
        // Set a 15 minute reminder if appropriate
        if (![self hasDeliveredAlertType:LeaveInFifteenMinutesReminder] && // Haven't fire a 15 min reminder yet
            ![self hasDeliveredAlertType:LeaveNowReminder] && // Haven't fired a leave now reminder yet (would be confusing!)
            [self.leaveForAirporTime timeIntervalSinceNow] >= 900.0) { // Leave time is at least 15 min in the future
            UILocalNotification *fifteenMinAlert = [[UILocalNotification alloc] init];
            
            if ([self.destination.terminal length] > 0) {
                // Special treatment for international terminals
                if ([[self.destination.terminal uppercaseString] isEqualToString:@"I"]) {
                    fifteenMinAlert.alertBody = [NSString stringWithFormat:@"Leave for %@ in 15 min. Flight %@ arrives at the international terminal.",
                                                 airportNameOrCode,
                                                 self.flightNumber];
                }
                else {
                    fifteenMinAlert.alertBody = [NSString stringWithFormat:@"Leave for %@ in 15 min. Flight %@ arrives at terminal %@.",
                                                 airportNameOrCode,
                                                 self.flightNumber,
                                                 self.destination.terminal];
                }
            }
            else {
                fifteenMinAlert.alertBody = [NSString stringWithFormat:@"Leave for %@ in 15 min. Flight %@ arrives soon.",
                                      airportNameOrCode,
                                      self.flightNumber];
            }
            
            fifteenMinAlert.fireDate = [NSDate dateWithTimeInterval:-900.0 sinceDate:leaveForAirporTime];
            
            // TODO: Custom leave sound
            fifteenMinAlert.soundName = @"announcement.caf";
            
            // Add some information to the alert so we can find it later
            fifteenMinAlert.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:flightID, @"flightID",
                                        [NSNumber numberWithInt:LeaveInFifteenMinutesReminder], @"reminderType", nil];
            
            [self scheduleAlert:fifteenMinAlert];
        }
        
        // Set a leave now reminder if appropriate (if we haven't fired it yet)
        if (![self hasDeliveredAlertType:LeaveNowReminder]) {
            UILocalNotification *leaveNowAlert = [[UILocalNotification alloc] init];
            
            if ([self.destination.terminal length] > 0) {
                if ([self.destination.terminal isEqualToString:@"I"]) {
                    leaveNowAlert.alertBody = [NSString stringWithFormat:@"Leave now for %@. Flight %@ arrives at the international terminal.",
                                               airportNameOrCode,
                                               self.flightNumber];
                }
                else {
                    leaveNowAlert.alertBody = [NSString stringWithFormat:@"Leave now for %@. Flight %@ arrives at terminal %@.",
                                               airportNameOrCode,
                                               self.flightNumber,
                                               self.destination.terminal];
                }
            }
            else {
                leaveNowAlert.alertBody = [NSString stringWithFormat:@"Leave now for %@. Flight %@ arrives soon.",
                                             airportNameOrCode,
                                             self.flightNumber];
            }
            
            leaveNowAlert.fireDate = leaveForAirporTime;
            
            // TODO: Custom leave sound
            leaveNowAlert.soundName = @"announcement.caf";
            
            // Add some information to the alert so we can find it later
            leaveNowAlert.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:flightID, @"flightID",
                                        [NSNumber numberWithInt:LeaveNowReminder], @"reminderType", nil];
            [self scheduleAlert:leaveNowAlert];
        }
    }
}


- (void)cancelLeaveAlerts {
    NSArray *alerts = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *alert in alerts) {
        if ([self matchesAlert:alert]) {
            [[UIApplication sharedApplication] cancelLocalNotification:alert];
        }
    }
}


- (BOOL)matchesAlert:(UILocalNotification *)alert {
    return [self.flightID isEqualToString:[[alert userInfo] valueForKeyOrNil:@"flightID"]];
}


- (BOOL)hasDeliveredAlertType:(LeaveForAirportReminderType)type {
    for (UILocalNotification *alert in scheduledAlerts) {
        if ([[[alert userInfo] valueForKey:@"reminderType"] integerValue] == type &&
            [alert.fireDate compare:[NSDate date]] == NSOrderedAscending) {
            return YES;
        }
    }
    
    return NO;
}


- (void)scheduleAlert:(UILocalNotification *)newAlert {
    // Remove all conflicting alerts of the same type
    NSMutableArray *alertsToRemove = [[NSMutableArray alloc] init];
    
    for (UILocalNotification *alert in scheduledAlerts) {
        if ([[[alert userInfo] valueForKey:@"reminderType"] integerValue] == 
            [[[newAlert userInfo] valueForKey:@"reminderType"] integerValue]) {
            [alertsToRemove addObject:alert];
            [[UIApplication sharedApplication] cancelLocalNotification:alert];
        }
    }
    
    [scheduledAlerts removeObjectsInArray:alertsToRemove];
    [scheduledAlerts addObject:newAlert];
    [[UIApplication sharedApplication] scheduleLocalNotification:newAlert];
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
        
        self.actualArrivalTime = [aDecoder decodeObjectForKey:@"actualArrivalTime"];
        self.actualDepartureTime = [aDecoder decodeObjectForKey:@"actualDepartureTime"];
        self.estimatedArrivalTime = [aDecoder decodeObjectForKey:@"estimatedArrivalTime"];
        self.scheduledDepartureTime = [aDecoder decodeObjectForKey:@"scheduledDepartureTime"];
        _scheduledArrivalTime = [aDecoder decodeObjectForKey:@"scheduledArrivalTime"];
        self.lastUpdated = [aDecoder decodeObjectForKey:@"lastUpdated"];
        self.leaveForAirporTime = [aDecoder decodeObjectForKey:@"leaveForAirportTime"];
        self.scheduledFlightDuration = [aDecoder decodeDoubleForKey:@"scheduledFlightDuration"];
        
        self.origin = [aDecoder decodeObjectForKey:@"origin"];
        self.destination = [aDecoder decodeObjectForKey:@"destination"];
        
        self.status = [aDecoder decodeIntegerForKey:@"status"];
        self.detailedStatus = [aDecoder decodeObjectForKey:@"detailedStatus"];
        
        _lastTracked = [aDecoder decodeObjectForKey:@"_lastTracked"];
        self.scheduledAlerts = [aDecoder decodeObjectForKey:@"scheduledAlerts"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Archive each instance variable under its variable name
    [aCoder encodeObject:flightID forKey:@"flightID"];
    [aCoder encodeObject:flightNumber forKey:@"flightNumber"];
    
    [aCoder encodeObject:actualArrivalTime forKey:@"actualArrivalTime"];
    [aCoder encodeObject:actualDepartureTime forKey:@"actualDepartureTime"];
    [aCoder encodeObject:estimatedArrivalTime forKey:@"estimatedArrivalTime"];
    [aCoder encodeObject:scheduledDepartureTime forKey:@"scheduledDepartureTime"];
    [aCoder encodeObject:_scheduledArrivalTime forKey:@"scheduledArrivalTime"];
    [aCoder encodeObject:lastUpdated forKey:@"lastUpdated"];
    [aCoder encodeObject:leaveForAirporTime forKey:@"leaveForAirportTime"];
    [aCoder encodeDouble:scheduledFlightDuration forKey:@"scheduledFlightDuration"];
    
    [aCoder encodeObject:origin forKey:@"origin"];
    [aCoder encodeObject:destination forKey:@"destination"];
    
    [aCoder encodeInteger:status forKey:@"status"];
    [aCoder encodeObject:detailedStatus forKey:@"detailedStatus"];
    
    [aCoder encodeObject:_lastTracked forKey:@"_lastTracked"];
    [aCoder encodeObject:scheduledAlerts forKey:@"scheduledAlerts"];
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
                
                [actualArrivalTime isEqualToDate:aFlight.actualArrivalTime] &&
                [actualDepartureTime isEqualToDate:aFlight.actualDepartureTime] &&
                [estimatedArrivalTime isEqualToDate:aFlight.estimatedArrivalTime] &&
                [scheduledDepartureTime isEqualToDate:aFlight.scheduledDepartureTime] &&
                [_scheduledArrivalTime isEqualToDate:aFlight.scheduledArrivalTime] &&
                [lastUpdated isEqualToDate:aFlight.lastUpdated] &&
                [leaveForAirporTime isEqualToDate:aFlight.leaveForAirporTime] &&
                scheduledFlightDuration == aFlight.scheduledFlightDuration &&
                
                [origin isEqual:aFlight.origin] &&
                [destination isEqual:aFlight.destination] &&
                
                status == aFlight.status &&
                [detailedStatus isEqualToString:aFlight.detailedStatus] &&
                
                [_lastTracked isEqualToDate:aFlight.lastTracked] &&
                [scheduledAlerts isEqualToArray:aFlight.scheduledAlerts]);
    }
    else {
        return NO;
    }
}

- (NSString *)description {
    // Be able to nicely print a flight with only the information sent by the server
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                          flightID ? flightID : [NSNull null], @"flightID",
                          flightNumber ? flightNumber : [NSNull null], @"flightNumber",
                          
                          actualArrivalTime ? actualArrivalTime : [NSNull null], @"actualArrivalTime",
                          actualDepartureTime ? actualDepartureTime : [NSNull null], @"actualDepartureTime",
                          estimatedArrivalTime ? estimatedArrivalTime : [NSNull null], @"estimatedArrivalTime",
                          scheduledDepartureTime ? scheduledDepartureTime : [NSNull null], @"scheduledDepartureTime",
                          lastUpdated ? lastUpdated : [NSNull null], @"lastUpdated",
                          leaveForAirporTime ? leaveForAirporTime : [NSNull null], @"leaveForAirportTime",
                          [NSNumber numberWithDouble:scheduledFlightDuration], @"scheduledFlightDuration",
                          
                          origin ? [origin toDict] : [NSNull null], @"origin",
                          destination ? [destination toDict] : [NSNull null], @"destination",
                          
                          [_statuses objectAtIndex:status], @"status",
                          detailedStatus ? detailedStatus : [NSNull null], @"detailedStatus", nil];
    return [info description];
}

@end
