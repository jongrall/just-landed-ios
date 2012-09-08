//
//  JLTrackStyles.h
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextStyle.h"
#import "LabelStyle.h"
#import "ButtonStyle.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Element Positions & Sizes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern CGRect const TRACK_HEADER_FRAME;
extern CGRect const TRACK_FOOTER_FRAME;
extern CGPoint const LOOKUP_BUTTON_ORIGIN;
extern CGRect const STATUS_LABEL_FRAME;
extern CGRect const ORIGIN_CODE_LABEL_FRAME;
extern CGRect const ORIGIN_CITY_LABEL_FRAME;
extern CGPoint const ARROW_ORIGIN;
extern CGRect const DESTINATION_CODE_LABEL_FRAME;
extern CGRect const DESTINATION_CITY_LABEL_FRAME;
extern CGRect const FLIGHT_PROGRESS_FRAME;
extern CGRect const LANDS_AT_LABEL_FRAME;
extern CGRect const LANDS_AT_TIME_FRAME;
extern CGSize const TIME_UNIT_OFFSET;
extern CGSize const TIME_UNIT_OFFSET_ALT;
extern CGSize const TIMEZONE_OFFSET;
extern CGRect const TERMINAL_LABEL_FRAME;
extern CGRect const TERMINAL_VALUE_FRAME;
extern CGRect const DRIVING_TIME_LABEL_FRAME;
extern CGRect const DRIVING_TIME_VALUE_FRAME;
extern CGRect const DIRECTIONS_BUTTON_FRAME;
extern CGRect const LEAVE_IN_GAUGE_FRAME;
extern CGPoint const LEAVE_IN_VALUE_ORIGIN;
extern CGPoint const LEAVE_IN_UNIT_ORIGIN;
extern CGPoint const LEAVE_IN_INSTRUCTIONS_ORIGIN;
extern CGPoint const LEAVE_NOW_ORIGIN;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods for Calculating Styles Based on Other Inputs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface JLTrackStyles : NSObject

+ (ButtonStyle *)lookupButtonStyle;
+ (ButtonStyle *)directionsButtonStyle;
+ (LabelStyle *)statusLabelStyle;
+ (LabelStyle *)airportCodeStyle;
+ (LabelStyle *)cityNameStyle;
+ (LabelStyle *)flightDataLabelStyle;
+ (LabelStyle *)flightDataValueStyle;
+ (LabelStyle *)timeUnitLabelStyle;
+ (LabelStyle *)timezoneLabelStyle;
+ (LabelStyle *)leaveTimeLargeLabelStyle;
+ (LabelStyle *)leaveTimeLargeUnitStyle;
+ (LabelStyle *)leaveTimeSmallLabelStyle;
+ (LabelStyle *)leaveTimeSmallUnitStyle;
+ (LabelStyle *)leaveInstructionsLabelStyle;
+ (LabelStyle *)leaveNowStyle;

@end
