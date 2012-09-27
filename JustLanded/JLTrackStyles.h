//
//  JLTrackStyles.h
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelStyle.h"
#import "ButtonStyle.h"

@interface JLTrackStyles : NSObject

+ (CGRect)trackHeaderFrame;
+ (CGRect)trackFooterFrame;
+ (CGPoint)lookupButtonOrigin;
+ (CGRect)statusLabelFrame;
+ (CGRect)originCodeLabelFrame;
+ (CGRect)originCityLabelFrame;
+ (CGPoint)arrowOrigin;
+ (CGRect)destinationCodeLabelFrame;
+ (CGRect)destinationCityLabelFrame;
+ (CGRect)flightProgressFrame;
+ (CGRect)landsAtLabelFrame;
+ (CGRect)landsAtTimeFrame;
+ (CGSize)timeUnitOffset;
+ (CGSize)timeUnitOffsetAlt;
+ (CGSize)timezoneOffset;
+ (CGRect)terminalLabelFrame;
+ (CGRect)terminalValueFrame;
+ (CGRect)drivingTimeLabelFrame;
+ (CGRect)drivingTimeValueFrame;
+ (CGRect)warningButtonFrame;
+ (CGRect)directionsButtonFrame;
+ (CGRect)leaveInGaugeFrame;
+ (CGPoint)leaveInValueOrigin;
+ (CGPoint)leaveInUnitOrigin;
+ (CGPoint)leaveInInstructionsOrigin;
+ (CGPoint)leaveNowOrigin;
+ (ButtonStyle *)lookupButtonStyle;
+ (ButtonStyle *)warningButtonStyle;
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
