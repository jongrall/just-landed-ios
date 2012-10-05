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


@implementation JLTrackStyles

+ (CGRect)trackHeaderFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 0.0f}, {320.0f, 170.0f}};
    }
    else {
        return (CGRect) {{0.0f, 0.0f}, {320.0f, 150.0f}};
    }
}


+ (CGRect)trackFooterFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 274.0f}, {320.0f, 274.0f}};
    }
    else {
        return (CGRect) {{0.0f, 220.0f}, {320.0f, 240.0f}};
    }
}


+ (CGPoint)lookupButtonOrigin {
    if ([UIScreen isMainScreenWide]) {
        return (CGPoint) {15.0f, 19.0f};
    }
    else {
        return (CGPoint) {15.0f, 15.0f};
    }
}


+ (CGRect)statusLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{136.0f, 15.0f}, {175.0f, 46.0f}};
    }
    else {
        return (CGRect) {{136.0f, 11.0f}, {175.0f, 46.0f}};
    }
}


+ (CGRect)originCodeLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{8.0f, 67.0f}, {137.0f, 70.0f}};
    }
    else {
        return (CGRect) {{8.0f, 58.0f}, {137.0f, 70.0f}};
    }
}


+ (CGRect)originCityLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{8.0f, 126.0f}, {137.0f, 20.0f}};
    }
    else {
        return (CGRect) {{8.0f, 117.0f}, {137.0f, 20.0f}};
    }
}


+ (CGPoint)arrowOrigin {
    if ([UIScreen isMainScreenWide]) {
        return (CGPoint) {144.0f, 85.0f};
    }
    else {
        return (CGPoint) {144.0f, 76.0f};
    }
}


+ (CGRect)destinationCodeLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{175.0f, 67.0f}, {137.0f, 70.0f}};
    }
    else {
        return (CGRect) {{175.0f, 58.0f}, {137.0f, 70.0f}};
    }
}


+ (CGRect)destinationCityLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{175.0f, 126.0f}, {137.0f, 20.0f}};
    }
    else {
        return (CGRect) {{175.0f, 117.0f}, {137.0f, 20.0f}};
    }
}


+ (CGRect)flightProgressFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 170.0f}, {320.0f, 104.0f}};
    }
    else {
        return (CGRect) {{0.0f, 150.0f}, {320.0f, 70.0f}};
    }
}


+ (CGRect)landsAtLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{19.0f, 296.0f}, {160.0f, 20.0f}};
    }
    else {
        return (CGRect) {{19.0f, 244.0f}, {160.0f, 20.0f}};
    }
}


+ (CGRect)landsAtTimeFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{19.0f, 308.0f}, {160.0f, 40.0f}};
    }
    else {
        return (CGRect) {{19.0f, 253.0f}, {160.0f, 40.0f}};
    }
}


+ (CGSize)timeUnitOffset {
    return (CGSize) {1.0f, 23.0f};
}


+ (CGSize)timeUnitOffsetAlt {
    return (CGSize) {1.0f, 11.0f};
}


+ (CGSize)timezoneOffset {
    return (CGSize) {0.0f, 23.0f};
}


+ (CGRect)terminalLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{19.0f, 387.0f}, {120.0f, 20.0f}};
    }
    else {
        return (CGRect) {{19.0f, 317.0f}, {120.0f, 20.0f}};
    }
}


+ (CGRect)terminalValueFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{19.0f, 399.0f}, {160.0f, 40.0f}};
    }
    else {
        return (CGRect) {{19.0f, 326.0f}, {160.0f, 40.0f}};
    }
}


+ (CGRect)drivingTimeLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{19.0f, 478.0f}, {120.0f, 20.0f}};
    }
    else {
        return (CGRect) {{19.0f, 392.0f}, {120.0f, 20.0f}};
    }
}


+ (CGRect)drivingTimeValueFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{19.0f, 490.0f}, {200.0f, 40.0f}};
    }
    else {
        return (CGRect) {{19.0f, 400.0f}, {200.0f, 40.0f}};
    }
}


+ (CGRect)warningButtonFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{167.0f, 360.0f},{86.0f, 86.0f}};
    }
    else {
        return (CGRect) {{167.0f, 280.0f},{86.0f, 86.0f}};
    }
}


+ (CGRect)directionsButtonFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{267.0f, 498.0f}, {38.0f, 34.0f}};
    }
    else {
        return (CGRect) {{267.0f, 412.0f}, {38.0f, 34.0f}};
    }
}


+ (CGRect)leaveInGaugeFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{115.0f, 316.0f}, {190.0f, 190.0f}};
    }
    else {
        return (CGRect) {{115.0f, 236.0f}, {190.0f, 190.0f}};
    }
}


+ (CGPoint)leaveInValueOrigin {
    return (CGPoint) {0.0f, 62.0f};
}


+ (CGPoint)leaveInUnitOrigin {
    return (CGPoint) {0.0f, 120.0f};
}


+ (CGPoint)leaveInInstructionsOrigin {
    return (CGPoint) {0.0f, 145.0f};
}


+ (CGPoint)leaveNowOrigin {
    return (CGPoint) {0.0f, 65.0f};
}


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


+ (ButtonStyle *)warningButtonStyle {
    static ButtonStyle *sWarningButtonStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        sWarningButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil
                                                   disabledLabelStyle:nil
                                                      backgroundColor:nil
                                                              upImage:[UIImage imageNamed:@"button_notification_up"]
                                                            downImage:[UIImage imageNamed:@"button_notification_down"]
                                                        disabledImage:nil
                                                            iconImage:nil
                                                    iconDisabledImage:nil
                                                           iconOrigin:CGPointZero
                                                          labelInsets:UIEdgeInsetsZero
                                                      downLabelOffset:CGSizeZero
                                                  disabledLabelOffset:CGSizeZero];
    });
    
    return sWarningButtonStyle;
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
