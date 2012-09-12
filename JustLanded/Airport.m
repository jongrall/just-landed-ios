//
//  Airport.m
//  Just Landed
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "Airport.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Airport

@synthesize iataCode = iataCode_;
@synthesize icaoCode = icaoCode_;
@synthesize city = city_;
@synthesize name = name_;
@synthesize location = location_;
@synthesize terminal = terminal_;
@synthesize timezone = timezone_;

- (id)initWithAirportInfo:(NSDictionary *)airportInfo {
    self = [super init];
    
    if (self) {
        iataCode_ = [airportInfo valueForKeyOrNil:@"iataCode"];
        icaoCode_ = [airportInfo valueForKeyOrNil:@"icaoCode"];
        city_ = [airportInfo valueForKeyOrNil:@"city"];
        name_ = [airportInfo valueForKeyOrNil:@"name"];
        location_ = [[CLLocation alloc] initWithLatitude:[[airportInfo valueForKeyOrNil:@"latitude"] doubleValue]
                                                   longitude:[[airportInfo valueForKeyOrNil:@"longitude"] doubleValue]];
        terminal_ = [airportInfo valueForKeyOrNil:@"terminal"];
        
        NSString *tzName = [airportInfo valueForKeyOrNil:@"timezone"];
        if (tzName && [tzName length] > 0) {
            timezone_ = [NSTimeZone timeZoneWithName:tzName];
        }
    }
    
    return self;
}


- (NSString *)bestAirportCode {
    NSString *code = (self.iataCode) ? self.iataCode : self.icaoCode;
    return [code uppercaseString];
}


- (NSDictionary *)toDict {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            self.iataCode ? self.iataCode : [NSNull null], @"iataCode",
            self.icaoCode ? self.icaoCode : [NSNull null], @"icaoCode",
            self.city ? self.city : [NSNull null], @"city",
            self.name ? self.name : [NSNull null], @"name",
            self.location ? self.location : [NSNull null], @"location",
            self.terminal ? self.terminal : [NSNull null], @"terminal",
            self.timezone ? self.timezone : [NSNull null], @"timezone", nil];
}


- (NSDictionary *)toJSONFriendlyDict {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            self.iataCode ? self.iataCode : [NSNull null], @"iataCode",
            self.icaoCode ? self.icaoCode : [NSNull null], @"icaoCode",
            self.city ? self.city : [NSNull null], @"city",
            self.name ? self.name : [NSNull null], @"name",
            self.location ? [NSNumber numberWithDouble:self.location.coordinate.latitude] : [NSNull null], @"latitude",
            self.location ? [NSNumber numberWithDouble:self.location.coordinate.longitude] : [NSNull null], @"longitude",
            self.terminal ? self.terminal : [NSNull null], @"terminal",
            self.timezone ? [self.timezone name] : [NSNull null], @"timezone", nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Conforming to NSCoding
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.iataCode = [aDecoder decodeObjectForKey:@"iataCode"];
        self.icaoCode = [aDecoder decodeObjectForKey:@"icaoCode"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.terminal = [aDecoder decodeObjectForKey:@"terminal"];
        self.timezone = [aDecoder decodeObjectForKey:@"timezone"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Encode each property using its name
    [aCoder encodeObject:self.iataCode forKey:@"iataCode"];
    [aCoder encodeObject:self.icaoCode forKey:@"icaoCode"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.terminal forKey:@"terminal"];
    [aCoder encodeObject:self.timezone forKey:@"timezone"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSString *)description {
    return [[self toDict] description];
}


@end
