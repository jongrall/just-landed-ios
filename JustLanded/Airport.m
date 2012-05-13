//
//  Airport.m
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import "Airport.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Begin Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Airport

@synthesize iataCode;
@synthesize icaoCode;

@synthesize city;
@synthesize location;

@synthesize terminal;
@synthesize timezone;


- (id)initWithAirportInfo:(NSDictionary *)info {
    self = [super init];
    
    if (self) {
        self.iataCode = [info valueForKeyOrNil:@"iataCode"];
        self.icaoCode = [info valueForKeyOrNil:@"icaoCode"];
        self.city = [info valueForKeyOrNil:@"city"];
        self.location = [[CLLocation alloc] initWithLatitude:[[info valueForKeyOrNil:@"latitude"] doubleValue]
                                                   longitude:[[info valueForKeyOrNil:@"longitude"] doubleValue]];
        self.terminal = [info valueForKeyOrNil:@"terminal"];
        
        NSString *tzName = [info valueForKeyOrNil:@"timezone"];
        if (tzName && [tzName length] > 0) {
            self.timezone = [NSTimeZone timeZoneWithName:tzName];
        }
    }
    
    return self;
}


- (NSString *)bestCode {
    NSString *code = (iataCode) ? iataCode : icaoCode;
    return [code uppercaseString];
}


- (NSDictionary *)toDict {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            iataCode ? iataCode : [NSNull null], @"iataCode",
            icaoCode ? icaoCode : [NSNull null], @"icaoCode",         
            city ? city : [NSNull null], @"city",
            location ? location : [NSNull null], @"location",            
            terminal ? terminal : [NSNull null], @"terminal", nil];
}


- (NSDictionary *)toJSONFriendlyDict {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            iataCode ? iataCode : [NSNull null], @"iataCode",
            icaoCode ? icaoCode : [NSNull null], @"icaoCode",         
            city ? city : [NSNull null], @"city",
            location ? [NSNumber numberWithDouble:location.coordinate.latitude] : [NSNull null], @"latitude",
            location ? [NSNumber numberWithDouble:location.coordinate.longitude] : [NSNull null], @"longitude",
            terminal ? terminal : [NSNull null], @"terminal", nil];
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
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.terminal = [aDecoder decodeObjectForKey:@"terminal"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Encode each property using its name
    [aCoder encodeObject:iataCode forKey:@"iataCode"];
    [aCoder encodeObject:icaoCode forKey:@"icaoCode"];
    [aCoder encodeObject:city forKey:@"city"];
    [aCoder encodeObject:location forKey:@"location"];
    [aCoder encodeObject:terminal forKey:@"terminal"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSString *)description {
    return [[self toDict] description];
}


@end
