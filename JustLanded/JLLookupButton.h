//
//  JLLookupButton.h
//  JustLanded
//
//  Created by Jon Grall on 4/15/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLButton.h"
#import "Flight.h"

@interface JLLookupButton : JLButton

@property (nonatomic) FlightStatus status;

- (id)initWithButtonStyle:(ButtonStyle *)aStyle frame:(CGRect)aFrame status:(FlightStatus)aStatus;

@end
