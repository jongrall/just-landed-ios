//
//  Flight.m
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "Flight.h"

@interface Flight () 

@property (nonatomic) BOOL didBeginTracking;

+ (NSString *)lookupPath:(NSString *)flightNumber;
- (NSString *)trackPath;
- (NSString *)stopTrackingPath;
        
@end


@implementation Flight

@synthesize actualArrivalTime;
@synthesize actualDepartureTime;
@synthesize destination;
@synthesize detailedStatus;
@synthesize didBeginTracking;
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


+ (NSString *)lookupPath:(NSString *)flightNumber {
    return [NSString stringWithFormat:LOOKUP_URL_FORMAT, flightNumber];
}


- (NSString *)trackPath {
    return [NSString stringWithFormat:TRACK_URL_FORMAT, self.flightNumber, self.flightID];
}


- (NSString *)stopTrackingPath {
    return [NSString stringWithFormat:UNTRACK_URL_FORMAT, self.flightID];
}


+ (void)lookupFlights:(NSString *)flightNumber {
    NSString *lookupPath = [self lookupPath:flightNumber];
    JustLandedAPIClient *client = [JustLandedAPIClient sharedClient];
       
    [client getPath:lookupPath 
         parameters:nil 
            success:^(AFHTTPRequestOperation *operation, id JSON){                
                if (JSON && [JSON isKindOfClass:[NSArray class]]) {
                    NSArray *listOfFlightInfo = (NSArray *)JSON;
                    
                    // Got the flight data, return a list of flights
//                    NSMutableArray *listOfFlights = [[NSMutableArray alloc] init];
                    
//                    for (NSDictionary *info in listOfFlightInfo) {
//                        [listOfFlights addObject:[[Flight alloc] initWithFlightInfo:info]];
//                    }
                    
                    // TODO: Post success notification with fetched flights attached
                    NSLog(@"%@", listOfFlightInfo);
                }

            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {                
                // TODO: Post lookup failed notification
                NSHTTPURLResponse *response = [operation response];
                
                if (response) {
                    switch ([response statusCode]) {
                        case 400:
                            // Invalid flight number
                            // TODO: Post lookup failed notification
                            break;
                        case 404:
                            // Flight not found
                            // TODO: Post lookup failed notification
                            break;
                        default:
                            break;
                    }
                }
                else {
                    // TODO: Handle connection problem
                    
                }
            }];
}


- (id)initWithFlightInfo:(NSDictionary *)info {
    // TODO: Implement me
    self = [super init];
    
    if (self) {
        return self;
    }
    return nil;
}


- (void)trackWithLocation:(CLLocation *)loc pushEnabled:(BOOL)pushFlag {
    NSString *trackingPath = [self trackPath];
    NSDictionary *trackingParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"latitude", [NSNumber numberWithFloat:loc.coordinate.latitude],
                                    @"longitude", [NSNumber numberWithFloat:loc.coordinate.longitude],
                                    @"begin_tracking", !self.didBeginTracking,
                                    @"push", [NSNumber numberWithBool:pushFlag], nil];
    
    JustLandedAPIClient *client = [JustLandedAPIClient sharedClient];
    [client getPath:trackingPath 
         parameters:trackingParams 
            success:^(AFHTTPRequestOperation *operation, id JSON){
                // TODO: Implement me
    
                // beginTracking flag is set only once for this instance
                if (!self.didBeginTracking) {
                    self.didBeginTracking = YES;
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            }];
}

- (void)stopTracking {
    // TODO: Implement me
}


@end
