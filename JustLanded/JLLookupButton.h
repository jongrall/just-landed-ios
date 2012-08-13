//
//  JLLookupButton.h
//  Just Landed
//
//  Created by Jon Grall on 4/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLButton.h"
#import "Flight.h"

@interface JLLookupButton : JLButton

@property (nonatomic) FlightStatus status;

- (id)initWithButtonStyle:(ButtonStyle *)aStyle frame:(CGRect)aFrame status:(FlightStatus)aStatus;

@end
