//
//  JLFlightProgressView.h
//  Just Landed
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;
#import "Flight.h"

@interface JLFlightProgressView : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) TimeOfDay timeOfDay;
@property (nonatomic) AircraftType aircraftType;

- (id)initWithFrame:(CGRect)aFrame progress:(CGFloat)someProgress timeOfDay:(TimeOfDay)aTimeOfDay aircraftType:(AircraftType)aType;
- (void)stopAnimating;

@end
