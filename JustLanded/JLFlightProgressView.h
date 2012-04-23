//
//  JLFlightProgressView.h
//  JustLanded
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flight.h"

extern const CGSize FLIGHT_PROGRESS_VIEW_SIZE;

@interface JLFlightProgressView : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) TimeOfDay timeOfDay;
@property (nonatomic) AircraftType aircraftType;

- (id)initWithFrame:(CGRect)frame progress:(CGFloat)someProgress timeOfDay:(TimeOfDay)tod aircraftType:(AircraftType)aType;
- (void)stopAnimating;

@end
