//
//  DestinationAirport.m
//  JustLanded
//
//  Created by Jon Grall on 2/23/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "DestinationAirport.h"

@implementation DestinationAirport

@synthesize bagClaim;
@synthesize gate;

- (id)initWithAirportInfo:(NSDictionary *)info {
    self = [super initWithAirportInfo:info];
    
    if (self) {
        self.bagClaim = [info valueForKeyOrNil:@"bagClaim"];
        self.gate = [info valueForKeyOrNil:@"gate"];
    }
    
    return self;
}


- (NSDictionary *)toDict {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:[super toDict]];
    [info setValue:bagClaim ? bagClaim : [NSNull null]
            forKey:@"bagClaim"];
    [info setValue:gate ? gate : [NSNull null]
            forKey:@"gate"];
    return info;
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
    [aCoder encodeObject:bagClaim forKey:@"bagClaim"];
    [aCoder encodeObject:gate forKey:@"gate"];
}

@end
