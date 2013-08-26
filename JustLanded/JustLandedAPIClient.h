//
//  Just LandedAPIClient.h
//  Just Landed
//
//  Created by Jon Grall on 2/17/12
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import Foundation;
#import "AFHTTPClient.h"


@interface JustLandedAPIClient : AFHTTPClient

+ (JustLandedAPIClient *)sharedClient;
+ (NSString *)lookupPathWithFlightNumber:(NSString *)flightNumber;
+ (NSString *)trackPathWithFlightNumber:(NSString *)flightNumber flightID:(NSString *)flightID;
+ (NSString *)stopTrackingPathWithFlightID:(NSString *)flightID;

@end
