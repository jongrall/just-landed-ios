//
//  DestinationAirport.m
//  Just Landed
//
//  Created by Jon Grall on 2/23/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "DestinationAirport.h"

@implementation DestinationAirport

- (id)initWithAirportInfo:(NSDictionary *)airportInfo {
    self = [super initWithAirportInfo:airportInfo];
    
    if (self) {
        self.bagClaim = [airportInfo valueForKeyOrNil:@"bagClaim"];
        self.gate = [airportInfo valueForKeyOrNil:@"gate"];
    }
    
    return self;
}


- (NSDictionary *)toDict {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:[super toDict]];
    [info setValue:(self.bagClaim ? self.bagClaim : [NSNull null]) forKey:@"bagClaim"];
    [info setValue:(self.gate ? self.gate : [NSNull null]) forKey:@"gate"];
    return info;
}


- (NSDictionary *)toJSONFriendlyDict {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:[super toJSONFriendlyDict]];
    [info setValue:(self.bagClaim ? self.bagClaim : [NSNull null]) forKey:@"bagClaim"];
    [info setValue:(self.gate ? self.gate : [NSNull null]) forKey:@"gate"];
    return info;
}


- (NSString *)bagClaim {
    if (self.bagClaim == nil || [self.bagClaim isKindOfClass:[NSNull class]]) {
        return @"";
    }
    else {
        return self.bagClaim;
    }
}


- (NSString *)gate {
    if (self.gate == nil || [self.gate isKindOfClass:[NSNull class]]) {
        return @"";
    }
    else {
        return self.gate;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Conforming to NSCoding
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.bagClaim = [aDecoder decodeObjectForKey:@"bagClaim"];
        self.gate = [aDecoder decodeObjectForKey:@"gate"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Encode each property using its name
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.bagClaim forKey:@"bagClaim"];
    [aCoder encodeObject:self.gate forKey:@"gate"];
}

@end
