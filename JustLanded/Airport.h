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

@property (nonatomic, retain) NSString *bagClaim;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *iataCode;
@property (nonatomic, retain) NSString *icaoCode;
@property (nonatomic) BOOL isDestination;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *terminal;

@end
