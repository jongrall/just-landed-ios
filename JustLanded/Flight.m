//
//  Flight.m
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "Flight.h"
#import "ASIHTTPRequest.h"

@interface Flight ()

+ (NSURL *)lookupURL:(NSString *)flightNumber;
- (NSURL *)trackURLwithLocation:(CLLocation *)loc
                    pushEnabled:(BOOL)pushFlag
                  beginTracking:(BOOL)beginFlag;
- (NSURL *)stopTrackingURL;
- (void)trackWithLocation:(CLLocation *)loc 
              pushEnabled:(BOOL)pushFlag
            beginTracking:(BOOL)beginFlag;
        
@end


@implementation Flight

@synthesize actualArrivalTime;
@synthesize actualDepartureTime;
@synthesize destination;
@synthesize detailedStatus;
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


+ (NSURL *)lookupURL:(NSString *)flightNumber {
    NSString *urlString = [NSString stringWithFormat:LOOKUP_URL_FORMAT,
                           BASE_URL,
                           flightNumber];
    return [[NSURL alloc] initWithString:urlString];
            
}


- (NSURL *)trackURLwithLocation:(CLLocation *)loc
                    pushEnabled:(BOOL)pushFlag
                  beginTracking:(BOOL)beginFlag {
    NSString *urlString;
    
    if (loc) {
        urlString = [NSString stringWithFormat:TRACK_URL_FORMAT,
                     BASE_URL,
                     self.flightNumber,
                     self.flightID,
                     loc.coordinate.latitude,
                     loc.coordinate.longitude,
                     beginFlag,
                     pushFlag];
    }
    else {
        urlString = [NSString stringWithFormat:TRACK_URL_FORMAT_NO_LOC,
                     BASE_URL,
                     self.flightNumber,
                     self.flightID,
                     beginFlag,
                     pushFlag];
    }
    
    return [[NSURL alloc] initWithString:urlString];
}


- (NSURL *)stopTrackingURL {
    NSString *urlString = [NSString stringWithFormat:UNTRACK_URL_FORMAT,
                           BASE_URL,
                           self.flightID];
    return [[NSURL alloc] initWithString:urlString];
}


+ (void)lookupFlights:(NSString *)flightNumber {
    NSURL *lookupURL = [self lookupURL:flightNumber];
    __block ASIHTTPRequest *req = [[ASIHTTPRequest alloc] initWithURL:lookupURL];
    
    [req setCompletionBlock:^{
        NSInteger status = [req responseStatusCode];
        
        switch (status) {
            case 200: {
                //Flights found
                NSData *data = [req responseData];
                
                NSError *parsingError;
                NSArray *listOfFlightInfo = [NSJSONSerialization
                                          JSONObjectWithData:data
                                                     options:NULL
                                                       error:&parsingError];
                if (!parsingError && listOfFlightInfo) {
                    // Got the flight data, return a list of flights
                    NSMutableArray *listOfFlights = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *info in listOfFlightInfo) {
                        [listOfFlights addObject:[[Flight alloc] initWithFlightInfo:info]];
                    }
                    
                    // TODO: Post success notification
                    
                }
                break;
            }
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
    }];
    
    [req setFailedBlock:^{
        NSError *error = [req error];
        
        // TODO: Post lookup failed notification
    }];
    
    [req startAsynchronous];
}


- (id)initWithFlightInfo:(NSDictionary *)info {
    // TODO: Implement me
    return nil;
}


- (void)beginTrackingWithLocation:(CLLocation *)loc
                      pushEnabled:(BOOL)pushFlag {
    [self trackWithLocation:loc 
                pushEnabled:pushFlag 
              beginTracking:YES];
}


- (void)updateWithLocation:(CLLocation *)loc {
    [self trackWithLocation:loc 
                pushEnabled:NO 
              beginTracking:NO];
}


- (void)trackWithLocation:(CLLocation *)loc 
              pushEnabled:(BOOL)pushFlag 
            beginTracking:(BOOL)beginFlag {
    // TODO: Implement me
}


- (void)stopTracking {
    // TODO: Implement me
}


@end
