//
//  Airport.h
//  Just Landed
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Airport : NSObject <NSCoding>

@property (copy, nonatomic) NSString *iataCode;
@property (copy, nonatomic) NSString *icaoCode;
@property (copy, nonatomic) NSString *city;
@property (strong, nonatomic) CLLocation *location;
@property (copy, nonatomic) NSString *terminal;
@property (strong, nonatomic) NSTimeZone *timezone;

- (id)initWithAirportInfo:(NSDictionary *)airportInfo;
- (NSDictionary *)toDict;
- (NSDictionary *)toJSONFriendlyDict;
- (NSString *)bestAirportCode;

@end
