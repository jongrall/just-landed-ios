//
//  Airport.m
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "Airport.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface Airport ()

- (void)populateWithAirportInfo:(NSDictionary *)info;
    
@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation Airport

@synthesize bagClaim;
@synthesize city;
@synthesize iataCode;
@synthesize icaoCode;
@synthesize isDestination;
@synthesize location;
@synthesize name;
@synthesize terminal;


- (id)initWithAirportCode:(NSString *)aCode name:(NSString *)aName city:(NSString *)aCity {
    NSDictionary *info = nil;
    
    if (aCode.length == 3) {
        // IATA code
        info = [[NSDictionary alloc] initWithObjectsAndKeys:
                aCode, @"iataCode",
                aName, @"name",
                aCity, @"city", nil];
    }
    else {
        // ICAO code
        info = [[NSDictionary alloc] initWithObjectsAndKeys:
                aCode, @"icaoCode",
                aName, @"name",
                aCity, @"city", nil];
    }
    
    return [self initWithAirportInfo:info];
}


- (id)initWithAirportInfo:(NSDictionary *)info {
    self = [super init];
    
    if (self) {
        [self populateWithAirportInfo:info];
        return self;
    }
    return nil;
}


- (void)populateWithAirportInfo:(NSDictionary *)info {
    self.bagClaim = [info valueForKeyOrNil:@"bagClaim"];
    self.city = [info valueForKeyOrNil:@"city"];
    self.iataCode = [info valueForKeyOrNil:@"iataCode"];
    self.icaoCode = [info valueForKeyOrNil:@"icaoCode"];
    self.location = [[CLLocation alloc] initWithLatitude:[[info valueForKeyOrNil:@"latitude"] doubleValue]
                                               longitude:[[info valueForKeyOrNil:@"longitude"] doubleValue]];
    self.name = [info valueForKeyOrNil:@"name"];
    self.terminal = [info valueForKeyOrNil:@"terminal"];
}


- (NSDictionary *)toDict {
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.bagClaim ? self.bagClaim : [NSNull null],
                          @"bagClaim",
                          self.city ? self.city : [NSNull null],
                          @"city",
                          self.iataCode ? self.iataCode : [NSNull null],
                          @"iataCode",
                          self.icaoCode ? self.icaoCode : [NSNull null],
                          @"icaoCode",
                          [NSNumber numberWithBool:self.isDestination],
                          @"isDestination",
                          self.location ? self.location : [NSNull null],
                          @"location",
                          self.name ? self.name : [NSNull null],
                          @"name",
                          self.terminal ? self.terminal : [NSNull null],
                          @"terminal", nil];
    return info;
}


- (NSString *)description {
    // Primarily for debugging purposes
    return [[self toDict] description];
}


@end
