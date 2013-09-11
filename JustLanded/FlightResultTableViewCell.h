//
//  FlightResultTableViewCell.h
//  Just Landed
//
//  Created by Jon Grall on 2/20/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;
#import "ABTableViewCell.h"

typedef NS_ENUM(NSUInteger, FlightResultCellType) {
    TOP = 0,
    MIDDLE,
    BOTTOM,
};

extern CGFloat const FlightResultTableViewCellWidth;
extern CGFloat const FlightResultTableViewCellHeight;

@interface FlightResultTableViewCell : ABTableViewCell

@property (copy, nonatomic) NSString *fromAirport;
@property (copy, nonatomic) NSString *toAirport;
@property (copy, nonatomic) NSString *status;
@property (strong, nonatomic) UIColor *statusColor;
@property (strong, nonatomic) UIColor *statusShadowColor;
@property (copy, nonatomic) NSString *landingTime;
@property (nonatomic) FlightResultCellType cellType;
@property (nonatomic) BOOL inFlight;

@end
