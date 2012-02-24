//
//  DestinationAirport.m
//  JustLanded
//
//  Created by Jon Grall on 2/23/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "DestinationAirport.h"

@implementation DestinationAirport

@synthesize bagClaim;

- (id)initWithAirportInfo:(NSDictionary *)info {
    self = [super initWithAirportInfo:info];
    
    if (self) {
        self.bagClaim = [info valueForKeyOrNil:@"bagClaim"];
    }
    
    return self;
}


- (NSDictionary *)toDict {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:[super toDict]];
    [info setValue:bagClaim ? bagClaim : [NSNull null]
            forKey:@"bagClaim"];
    return info;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Conforming to NSCoding
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.bagClaim = [aDecoder decodeObjectForKey:@"bagClaim"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Encode each property using its name
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:bagClaim forKey:@"bagClaim"];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Superclass overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        DestinationAirport *aDestinationAirport = (DestinationAirport *)object;
        return ([super isEqual:aDestinationAirport] && 
                [bagClaim isEqualToString:aDestinationAirport.bagClaim]);
    }
    else {
        return NO;
    }
}



@end
