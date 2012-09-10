//
//  DestinationAirport.m
//  Just Landed
//
//  Created by Jon Grall on 2/23/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "DestinationAirport.h"

@implementation DestinationAirport

@synthesize bagClaim = bagClaim_;
@synthesize gate = gate_;

- (id)initWithAirportInfo:(NSDictionary *)airportInfo {
    self = [super initWithAirportInfo:airportInfo];
    
    if (self) {
        bagClaim_ = [airportInfo valueForKeyOrNil:@"bagClaim"];
        gate_ = [airportInfo valueForKeyOrNil:@"gate"];
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
    if (bagClaim_ == nil || [bagClaim_ isKindOfClass:[NSNull class]]) {
        return @"";
    }
    else {
        return bagClaim_;
    }
}


- (NSString *)gate {
    if (gate_ == nil || [gate_ isKindOfClass:[NSNull class]]) {
        return @"";
    }
    else {
        return gate_;
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
