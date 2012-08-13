//
//  DestinationAirport.h
//  Just Landed
//
//  Created by Jon Grall on 2/23/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "Airport.h"

@interface DestinationAirport : Airport

@property (strong, nonatomic) NSString *bagClaim;
@property (strong, nonatomic) NSString *gate;

@end
