//
//  JLTrackStyles.m
//  JustLanded
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLTrackStyles.h"
#import "JLStyles.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Track Screen
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CGRect const TRACK_HEADER_FRAME = {0.0f, 0.0f, 320.0f, 150.0f};
CGRect const TRACK_FOOTER_FRAME = {0.0f, 220.0f, 320.0f, 240.0f};
CGPoint const LOOKUP_BUTTON_ORIGIN = {15.0f, 15.0f};
CGRect const STATUS_LABEL_FRAME = {136.0f, 11.5f, 175.0f, 46.0f};
CGRect const ORIGIN_CODE_LABEL_FRAME = {8.0f, 58.0f, 137.0f, 70.0f};
CGRect const ORIGIN_CITY_LABEL_FRAME = {8.0f, 117.0f, 137.0f, 20.0f};
CGPoint const ARROW_ORIGIN = {144.0f, 76.5f};
CGRect const DESTINATION_CODE_LABEL_FRAME = {175.0f, 58.0f, 137.0f, 70.0f};
CGRect const DESTINATION_CITY_LABEL_FRAME = {175.0f, 117.0f, 137.0f, 20.0f};
CGRect const FLIGHT_PROGRESS_FRAME = {0.0f, 150.0f, 320.0f, 70.0f};
CGRect const LANDS_AT_LABEL_FRAME = {19.0f, 244.0f, 120.0f, 20.0f};
CGRect const LANDS_AT_TIME_FRAME = {19.0f, 254.5f, 160.0f, 40.0f};
CGSize const TIME_UNIT_OFFSET = {1.0f, 23.0f};
CGRect const TERMINAL_LABEL_FRAME = {19.0f, 313.5f, 120.0f, 20.0f};
CGRect const TERMINAL_VALUE_FRAME = {19.0f, 323.0f, 160.0f, 40.0f};
CGRect const DRIVING_TIME_LABEL_FRAME = {19.0f, 382.5f, 120.0f, 20.0f};
CGRect const DRIVING_TIME_VALUE_FRAME = {19.0f, 392.0f, 200.0f, 40.0f};
CGRect const DIRECTIONS_BUTTON_FRAME = {267.0f, 412.0f, 38.0f, 34.0f};
CGRect const INFO_BUTTON_FRAME = {15.0f, 412.0f, 38.0f, 34.0f};
CGRect const LEAVE_IN_GAUGE_FRAME = {115.0f, 236.0f, 190.0f, 190.0f};
CGPoint const LEAVE_IN_VALUE_ORIGIN = {0.0f, 62.0f};
CGPoint const LEAVE_IN_UNIT_ORIGIN = {0.0f, 120.0f};
CGPoint const LEAVE_IN_INSTRUCTIONS_ORIGIN = {0.0f, 145.0f};
CGPoint const LEAVE_NOW_ORIGIN = {0.0f, 65.0f};


@implementation JLTrackStyles

static ButtonStyle *_lookupButtonStyle;
static ButtonStyle *_directionsButtonStyle;
static ButtonStyle *_infoButtonStyle;
static LabelStyle *_statusLabelStyle;
static LabelStyle *_airportCodeStyle;
static LabelStyle *_cityNameStyle;
static LabelStyle *_flightDataLabelStyle;
static LabelStyle *_flightDataValueStyle;
static LabelStyle *_timeUnitLabelStyle;
static LabelStyle *_leaveTimeLargeLabelStyle;
static LabelStyle *_leaveTimeLargeUnitStyle;
static LabelStyle *_leaveTimeSmallLabelStyle;
static LabelStyle *_leaveTimeSmallUnitStyle;
static LabelStyle *_leaveInstructionsLabelStyle;
static LabelStyle *_leaveNowStyle;

+ (ButtonStyle *)lookupButtonStyle {
    if (!_lookupButtonStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:14.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:nil
                                                  shadowOffset:CGSizeMake(0.0f, -1.0f)
                                                    shadowBlur:0.0f];
        
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                       backgroundColor:nil 
                                                             alignment:UITextAlignmentLeft 
                                                         lineBreakMode:UILineBreakModeClip];
        
        _lookupButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle
                                                  disabledLabelStyle:nil
                                                     backgroundColor:nil
                                                             upImage:nil
                                                           downImage:nil
                                                       disabledImage:nil
                                                           iconImage:nil
                                                   iconDisabledImage:nil
                                                          iconOrigin:CGPointMake(10.5f, 7.0f)
                                                         labelInsets:UIEdgeInsetsMake(11.5f, 31.5f, 8.0f, 11.0f)
                                                     downLabelOffset:CGSizeMake(0.0f, 1.0f)
                                                 disabledLabelOffset:CGSizeZero];
    }
    
    return _lookupButtonStyle;
}


+ (ButtonStyle *)directionsButtonStyle {
    if (!_directionsButtonStyle) {
        _directionsButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil 
                                                      disabledLabelStyle:nil
                                                         backgroundColor:nil
                                                                 upImage:[[UIImage imageNamed:@"small_button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)]
                                                               downImage:[[UIImage imageNamed:@"small_button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)] 
                                                           disabledImage:nil 
                                                               iconImage:[UIImage imageNamed:@"directions" withColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.8f]
                                                                                 shadowColor:[UIColor whiteColor] 
                                                                                shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                                                  shadowBlur:0.5f]
                                                       iconDisabledImage:nil
                                                              iconOrigin:CGPointMake(8.0f, 10.5)
                                                             labelInsets:UIEdgeInsetsZero
                                                         downLabelOffset:CGSizeMake(0.0f, 1.0f)
                                                     disabledLabelOffset:CGSizeZero];
    }
    
    return _directionsButtonStyle;
}


+ (ButtonStyle *)infoButtonStyle {
    if(!_infoButtonStyle) {
        _infoButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil
                                                disabledLabelStyle:nil
                                                   backgroundColor:nil
                                                           upImage:[[UIImage imageNamed:@"small_button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)]
                                                         downImage:[[UIImage imageNamed:@"small_button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)]
                                                     disabledImage:nil 
                                                         iconImage:[UIImage imageNamed:@"about" withColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.8f]
                                                                                                  shadowColor:[UIColor whiteColor] 
                                                                                                 shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                                                                   shadowBlur:0.5f]
                                                 iconDisabledImage:nil
                                                        iconOrigin:CGPointMake(14.0f, 6.0f)
                                                       labelInsets:UIEdgeInsetsZero
                                                   downLabelOffset:CGSizeMake(0.0f, 1.0f)
                                               disabledLabelOffset:CGSizeZero];
    }
    
    return _infoButtonStyle;
}


+ (LabelStyle *)statusLabelStyle {
    if (!_statusLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles regularScriptOfSize:34.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor blackColor]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:1.0f];
        
        _statusLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                  backgroundColor:nil
                                                        alignment:UITextAlignmentRight
                                                    lineBreakMode:UILineBreakModeClip];
    }
    
    return _statusLabelStyle;
}


+ (LabelStyle *)airportCodeStyle {
    if (!_airportCodeStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:54.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor blackColor]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:1.0f];
        
        _airportCodeStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                  backgroundColor:nil 
                                                        alignment:UITextAlignmentCenter 
                                                    lineBreakMode:UILineBreakModeClip];
    }
    
    return _airportCodeStyle;
}


+ (LabelStyle *)cityNameStyle {
    if (!_cityNameStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:12.0f]
                                                         color:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                   shadowColor:[UIColor blackColor]
                                                  shadowOffset:CGSizeMake(0.0f, -0.5f)
                                                    shadowBlur:1.5f];
        
        _cityNameStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                               backgroundColor:nil 
                                                     alignment:UITextAlignmentCenter 
                                                 lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    return _cityNameStyle;
}


+ (LabelStyle *)flightDataLabelStyle {
    if (!_flightDataLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:13.0f] 
                                                         color:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _flightDataLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                  backgroundColor:nil
                                                        alignment:UITextAlignmentLeft
                                                    lineBreakMode:UILineBreakModeClip];
    }
    
    return _flightDataLabelStyle;
}


+ (LabelStyle *)flightDataValueStyle {
    if (!_flightDataValueStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:33.0f] 
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _flightDataValueStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                  backgroundColor:nil
                                                        alignment:UITextAlignmentLeft
                                                    lineBreakMode:UILineBreakModeClip];
    }
    
    return _flightDataValueStyle;
}


+ (LabelStyle *)timeUnitLabelStyle {
    if (!_timeUnitLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:11.0f] 
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _timeUnitLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:UITextAlignmentLeft
                                                        lineBreakMode:UILineBreakModeClip];
    }
    
    return _timeUnitLabelStyle;
}

+ (LabelStyle *)leaveTimeLargeLabelStyle {
    if (!_leaveTimeLargeLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:70.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _leaveTimeLargeLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                     backgroundColor:nil 
                                                           alignment:UITextAlignmentCenter 
                                                       lineBreakMode:UILineBreakModeClip];
    }
    
    return _leaveTimeLargeLabelStyle;
}


+ (LabelStyle *)leaveTimeLargeUnitStyle {
    if (!_leaveTimeLargeUnitStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:10.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _leaveTimeLargeUnitStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                    backgroundColor:nil 
                                                          alignment:UITextAlignmentCenter 
                                                      lineBreakMode:UILineBreakModeClip];
    }
    
    return _leaveTimeLargeUnitStyle;
}


+ (LabelStyle *)leaveTimeSmallLabelStyle {
    if (!_leaveTimeSmallLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:33.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _leaveTimeSmallLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                          backgroundColor:nil 
                                                                alignment:UITextAlignmentCenter 
                                                            lineBreakMode:UILineBreakModeClip];
    }
    
    return _leaveTimeSmallLabelStyle;
}


+ (LabelStyle *)leaveTimeSmallUnitStyle {
    if (!_leaveTimeSmallUnitStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:10.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _leaveTimeSmallUnitStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                         backgroundColor:nil 
                                                               alignment:UITextAlignmentCenter 
                                                           lineBreakMode:UILineBreakModeClip];
    }
    
    return _leaveTimeSmallUnitStyle;
}


+ (LabelStyle *)leaveInstructionsLabelStyle {
    if (!_leaveInstructionsLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:12.5f]
                                                         color:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _leaveInstructionsLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                     backgroundColor:nil 
                                                           alignment:UITextAlignmentCenter 
                                                       lineBreakMode:UILineBreakModeClip];
    }
    
    return _leaveInstructionsLabelStyle;
}


+ (LabelStyle *)leaveNowStyle {
    if (!_leaveNowStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:25.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _leaveNowStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                     backgroundColor:nil 
                                                           alignment:UITextAlignmentCenter 
                                                       lineBreakMode:UILineBreakModeWordWrap];
    }
    
    return _leaveNowStyle;
}

@end