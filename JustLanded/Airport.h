//
//  Airport.h
//  JustLanded
//
//  Created by Jon Grall on 2/15/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Airport : NSObject

@property (strong, nonatomic) NSString *bagClaim;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *iataCode;
@property (strong, nonatomic) NSString *icaoCode;
@property (nonatomic) BOOL isDestination;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *terminal;

@end
