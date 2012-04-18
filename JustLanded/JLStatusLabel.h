//
//  JLStatusLabel.h
//  JustLanded
//
//  Created by Jon Grall on 4/15/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLLabel.h"
#import "Flight.h"

@interface JLStatusLabel : JLLabel

@property (nonatomic) FlightStatus status;

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame status:(FlightStatus)aStatus;

@end
