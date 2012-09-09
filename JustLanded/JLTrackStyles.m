//
//  JLTrackStyles.m
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLTrackStyles.h"
#import "JLStyles.h"
#import "TextStyle.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Track Screen
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CGRect const TRACK_HEADER_FRAME = {{0.0f, 0.0f}, {320.0f, 150.0f}};
CGRect const TRACK_FOOTER_FRAME = {{0.0f, 220.0f}, {320.0f, 240.0f}};
CGPoint const LOOKUP_BUTTON_ORIGIN = {15.0f, 15.0f};
CGRect const STATUS_LABEL_FRAME = {{136.0f, 11.0f}, {175.0f, 46.0f}};
CGRect const ORIGIN_CODE_LABEL_FRAME = {{8.0f, 58.0f}, {137.0f, 70.0f}};
CGRect const ORIGIN_CITY_LABEL_FRAME = {{8.0f, 117.0f}, {137.0f, 20.0f}};
CGPoint const ARROW_ORIGIN = {144.0f, 76.0f};
CGRect const DESTINATION_CODE_LABEL_FRAME = {{175.0f, 58.0f}, {137.0f, 70.0f}};
CGRect const DESTINATION_CITY_LABEL_FRAME = {{175.0f, 117.0f}, {137.0f, 20.0f}};
CGRect const FLIGHT_PROGRESS_FRAME = {{0.0f, 150.0f}, {320.0f, 70.0f}};
CGRect const LANDS_AT_LABEL_FRAME = {{19.0f, 244.0f}, {120.0f, 20.0f}};
CGRect const LANDS_AT_TIME_FRAME = {{19.0f, 253.0f}, {160.0f, 40.0f}};
CGSize const TIME_UNIT_OFFSET = {1.0f, 23.0f};
CGSize const TIME_UNIT_OFFSET_ALT = {1.0f, 11.0f};
CGSize const TIMEZONE_OFFSET = {0.0f, 23.0f};
CGRect const TERMINAL_LABEL_FRAME = {{19.0f, 317.0f}, {120.0f, 20.0f}};
CGRect const TERMINAL_VALUE_FRAME = {{19.0f, 326.0f}, {160.0f, 40.0f}};
CGRect const DRIVING_TIME_LABEL_FRAME = {{19.0f, 392.0f}, {120.0f, 20.0f}};
CGRect const DRIVING_TIME_VALUE_FRAME = {{19.0f, 400.0f}, {200.0f, 40.0f}};
CGRect const DIRECTIONS_BUTTON_FRAME = {{267.0f, 412.0f}, {38.0f, 34.0f}};
CGRect const LEAVE_IN_GAUGE_FRAME = {{115.0f, 236.0f}, {190.0f, 190.0f}};
CGPoint const LEAVE_IN_VALUE_ORIGIN = {0.0f, 62.0f};
CGPoint const LEAVE_IN_UNIT_ORIGIN = {0.0f, 120.0f};
CGPoint const LEAVE_IN_INSTRUCTIONS_ORIGIN = {0.0f, 145.0f};
CGPoint const LEAVE_NOW_ORIGIN = {0.0f, 65.0f};


@implementation JLTrackStyles

+ (ButtonStyle *)lookupButtonStyle {
    static ButtonStyle *sLookupButtonStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:14.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor clearColor]
                                                  shadowOffset:CGSizeMake(0.0f, -1.0f)
                                                    shadowBlur:0.0f];
        
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                       backgroundColor:nil 
                                                             alignment:UITextAlignmentLeft 
                                                         lineBreakMode:UILineBreakModeClip];
        
        sLookupButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle
                                                  disabledLabelStyle:nil
                                                     backgroundColor:nil
                                                             upImage:nil
                                                           downImage:nil
                                                       disabledImage:nil
                                                           iconImage:nil
                                                   iconDisabledImage:nil
                                                          iconOrigin:CGPointMake(10.0f, 7.0f)
                                                         labelInsets:UIEdgeInsetsMake(8.0f, 32.0f, 4.0f, 11.0f)
                                                     downLabelOffset:CGSizeMake(0.0f, 1.0f)
                                                 disabledLabelOffset:CGSizeZero];
    });
    
    return sLookupButtonStyle;
}


+ (ButtonStyle *)directionsButtonStyle {
    static dispatch_once_t sOncePredicate;
    static ButtonStyle *sDirectionsButtonStyle;
    
    dispatch_once(&sOncePredicate, ^{
        sDirectionsButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil
                                                      disabledLabelStyle:nil
                                                         backgroundColor:nil
                                                                 upImage:[[UIImage imageNamed:@"small_button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)]
                                                               downImage:[[UIImage imageNamed:@"small_button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)] 
                                                           disabledImage:nil 
                                                               iconImage:[UIImage imageNamed:@"directions" withColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.8f]
                                                                                 shadowColor:[UIColor whiteColor] 
                                                                                shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                                                  shadowBlur:1.0f]
                                                       iconDisabledImage:nil
                                                              iconOrigin:CGPointMake(8.0f, 10.0f)
                                                             labelInsets:UIEdgeInsetsZero
                                                         downLabelOffset:CGSizeMake(0.0f, 1.0f)
                                                     disabledLabelOffset:CGSizeZero];
    });
    
    return sDirectionsButtonStyle;
}


+ (LabelStyle *)statusLabelStyle {
    static LabelStyle *sStatusLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles regularScriptOfSize:34.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor blackColor]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:1.0f];
        
        sStatusLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                  backgroundColor:nil
                                                        alignment:UITextAlignmentRight
                                                    lineBreakMode:UILineBreakModeClip];
    });
    
    return sStatusLabelStyle;
}


+ (LabelStyle *)airportCodeStyle {
    static LabelStyle *sAirportCodeStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:54.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor blackColor]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:1.0f];
        
        sAirportCodeStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                  backgroundColor:nil 
                                                        alignment:UITextAlignmentCenter 
                                                    lineBreakMode:UILineBreakModeClip];
    });
    
    return sAirportCodeStyle;
}


+ (LabelStyle *)cityNameStyle {
    static LabelStyle *sCityNameStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:12.0f]
                                                         color:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                   shadowColor:[UIColor blackColor]
                                                  shadowOffset:CGSizeMake(0.0f, -0.5f)
                                                    shadowBlur:1.5f];
        
        sCityNameStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                               backgroundColor:nil 
                                                     alignment:UITextAlignmentCenter 
                                                 lineBreakMode:UILineBreakModeTailTruncation];
    });
    
    return sCityNameStyle;
}


+ (LabelStyle *)flightDataLabelStyle {
    static LabelStyle *sFlightDataLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:13.0f]
                                                         color:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sFlightDataLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:UITextAlignmentLeft
                                                        lineBreakMode:UILineBreakModeClip];
    });
    
    return sFlightDataLabelStyle;
}


+ (LabelStyle *)flightDataValueStyle {
    static LabelStyle *sFlightDataValueStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:33.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sFlightDataValueStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:UITextAlignmentLeft
                                                        lineBreakMode:UILineBreakModeClip];
    });
    
    return sFlightDataValueStyle;
}


+ (LabelStyle *)timeUnitLabelStyle {
    static LabelStyle *sTimeUnitLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:11.0f]
                                                         color:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sTimeUnitLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                    backgroundColor:nil
                                                          alignment:UITextAlignmentLeft
                                                      lineBreakMode:UILineBreakModeClip];
    });
    
    return sTimeUnitLabelStyle;
}


+ (LabelStyle *)timezoneLabelStyle {
    static LabelStyle *sTimezoneLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:11.0f]
                                                         color:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sTimezoneLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                    backgroundColor:nil
                                                          alignment:UITextAlignmentLeft
                                                      lineBreakMode:UILineBreakModeClip];
    });
    
    return sTimezoneLabelStyle;
}


+ (LabelStyle *)leaveTimeLargeLabelStyle {
    static LabelStyle *sLeaveTimeLargeLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:70.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sLeaveTimeLargeLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                          backgroundColor:nil 
                                                                alignment:UITextAlignmentCenter 
                                                            lineBreakMode:UILineBreakModeClip];
    });
    
    return sLeaveTimeLargeLabelStyle;
}


+ (LabelStyle *)leaveTimeLargeUnitStyle {
    static LabelStyle *sLeaveTimeLargeUnitStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:10.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sLeaveTimeLargeUnitStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                         backgroundColor:nil 
                                                               alignment:UITextAlignmentCenter 
                                                           lineBreakMode:UILineBreakModeClip];
    });
    
    return sLeaveTimeLargeUnitStyle;
}


+ (LabelStyle *)leaveTimeSmallLabelStyle {
    static LabelStyle *sLeaveTimeSmallLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:33.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sLeaveTimeSmallLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                          backgroundColor:nil 
                                                                alignment:UITextAlignmentCenter 
                                                            lineBreakMode:UILineBreakModeClip];
    });
    
    return sLeaveTimeSmallLabelStyle;
}


+ (LabelStyle *)leaveTimeSmallUnitStyle {
    static LabelStyle *sLeaveTimeSmallUnitStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifRomanOfSize:10.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sLeaveTimeSmallUnitStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                         backgroundColor:nil 
                                                               alignment:UITextAlignmentCenter 
                                                           lineBreakMode:UILineBreakModeClip];
    });
    
    return sLeaveTimeSmallUnitStyle;
}


+ (LabelStyle *)leaveInstructionsLabelStyle {
    static LabelStyle *sLeaveInstructionsLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:12.5f]
                                                         color:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sLeaveInstructionsLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                             backgroundColor:nil 
                                                                   alignment:UITextAlignmentCenter 
                                                               lineBreakMode:UILineBreakModeClip];
    });
    
    return sLeaveInstructionsLabelStyle;
}


+ (LabelStyle *)leaveNowStyle {
    static LabelStyle *sLeaveNowStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifBoldCondensedOfSize:25.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f] 
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sLeaveNowStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                               backgroundColor:nil
                                                     alignment:UITextAlignmentCenter
                                                 lineBreakMode:UILineBreakModeWordWrap];
    });
    
    return sLeaveNowStyle;
}

@end
