//
//  FlightResultTableViewCell.h
//  JustLanded
//
//  Created by Jon Grall on 2/20/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

extern CGFloat const FlightResultTableViewCellWidth;
extern CGFloat const FlightResultTableViewCellHeight;

@interface FlightResultTableViewCell : ABTableViewCell

@property (copy, nonatomic) NSString *fromAirport;
@property (copy, nonatomic) NSString *toAirport;
@property (copy, nonatomic) NSString *status;
@property (strong, nonatomic) UIColor *statusColor;
@property (copy, nonatomic) NSString *landingTime;

@end
