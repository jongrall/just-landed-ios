//
//  JLLookupStyles.m
//  JustLanded
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLookupStyles.h"

CGRect const LOGO_FRAME = {35.0f, 33.0f, 248.0f, 40.0f};
CGRect const LOOKUP_BUTTON_FRAME = {12.0f, 179.0f, 296.0f, 56.0f};
CGRect const AIRPORT_CODES_LABEL_FRAME = {20.0f, 204.0f, 280.0f, 30.0f};
CGRect const AIRPORT_CODES_BUTTON_FRAME = {229.0f, 201.0f, 33.0f, 34.0f};
CGRect const AIRLINE_NO_RESULTS_LABEL_FRAME = {20.0f, 57.0f, 280.0f, 40.0f};
CGRect const ABOUT_BUTTON_FRAME = {271.0f, 0.0f, 49.0f, 49.0f};
CGRect const LOOKUP_INPUT_FRAME = {14.0f, 117.0f, 292.0f, 49.0f};
CGRect const LOOKUP_TEXTFIELD_FRAME = {0.0f, 0.0f, 288.0f, 49.0f};
CGRect const LOOKUP_LABEL_FRAME = {0.0f, 0.0f, 150.0f, 49.0f};
CGPoint const LOOKUP_SEPARATOR_ORIGIN = {113.5f , 12.0f};
CGRect const LOOKUP_LABEL_TEXT_FRAME = {0.0f, 15.0f, 150.0f, 49.0f};
CGRect const LOOKUP_FIELD_FRAME = {0.0f, 0.0f, 100.0f, 49.0f};
CGRect const CLOUD_LAYER_FRAME = {0.0f, 168.0f, 320.0f, 30.0f};
CGRect const CLOUD_FOOTER_FRAME = {0.0f, 198.0f, 320.0f, 262.0f};
CGRect const RESULTS_TABLE_FRAME = {16.0f, 187.0f, 288.0f, 257.0f};
CGRect const RESULTS_TABLE_CONTAINER_FRAME = {15.0f, 185.0f, 290.0f, 261.0f};


@implementation JLLookupStyles

static ButtonStyle *_lookupButtonStyle;
static ButtonStyle *_aboutButtonStyle;
static ButtonStyle *_airportCodesButtonStyle;
static ButtonStyle *_airportCodesLabelButtonStyle;
static LabelStyle *_flightFieldLabelStyle;
static LabelStyle *_flightFieldTextStyle;
static LabelStyle *_airlineNoResultsLabelStyle;


+ (ButtonStyle *)lookupButtonStyle {
    if (!_lookupButtonStyle) {
        ButtonStyle *defaultStyle = [JLStyles defaultButtonStyle];
        
        // Override text alignment
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:defaultStyle.labelStyle.textStyle 
                                                       backgroundColor:defaultStyle.labelStyle.backgroundColor
                                                             alignment:UITextAlignmentLeft
                                                         lineBreakMode:defaultStyle.labelStyle.lineBreakMode];
        LabelStyle *disabledStyle = [[LabelStyle alloc] initWithTextStyle:defaultStyle.disabledLabelStyle.textStyle
                                                          backgroundColor:defaultStyle.disabledLabelStyle.backgroundColor
                                                                alignment:UITextAlignmentLeft 
                                                            lineBreakMode:defaultStyle.disabledLabelStyle.lineBreakMode];
        
        // Create from the default style and ovverride the icon and insets
        _lookupButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle
                                                  disabledLabelStyle:disabledStyle
                                                     backgroundColor:nil
                                                             upImage:defaultStyle.upImage
                                                           downImage:defaultStyle.downImage 
                                                       disabledImage:defaultStyle.disabledImage
                                                           iconImage:[UIImage imageNamed:@"lookup_glass" 
                                                                               withColor:defaultStyle.labelStyle.textStyle.color
                                                                             shadowColor:defaultStyle.labelStyle.textStyle.shadowColor
                                                                            shadowOffset:CGSizeMake(0.0f, -1.0f)
                                                                              shadowBlur:defaultStyle.labelStyle.textStyle.shadowBlur]
                                                   iconDisabledImage:[UIImage imageNamed:@"lookup_glass" 
                                                                               withColor:defaultStyle.disabledLabelStyle.textStyle.color
                                                                             shadowColor:defaultStyle.disabledLabelStyle.textStyle.shadowColor 
                                                                            shadowOffset:defaultStyle.disabledLabelStyle.textStyle.shadowOffset
                                                                              shadowBlur:defaultStyle.disabledLabelStyle.textStyle.shadowBlur]
                                                          iconOrigin:CGPointMake(73.0f, 11.0f)
                                                         labelInsets:UIEdgeInsetsMake(-3.0f, 104.0f, 0.0f, 20.0f) 
                                                     downLabelOffset:defaultStyle.downLabelOffset 
                                                 disabledLabelOffset:defaultStyle.disabledLabelOffset];
    }
    
    return _lookupButtonStyle;
}


+ (ButtonStyle *)aboutButtonStyle {
    if (!_aboutButtonStyle) {
        _aboutButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil 
                                                 disabledLabelStyle:nil 
                                                    backgroundColor:nil 
                                                            upImage:[UIImage imageNamed:@"about_up"] 
                                                          downImage:[UIImage imageNamed:@"about_down"]
                                                      disabledImage:nil
                                                          iconImage:nil 
                                                  iconDisabledImage:nil 
                                                         iconOrigin:CGPointZero 
                                                        labelInsets:UIEdgeInsetsZero 
                                                    downLabelOffset:CGSizeZero 
                                                disabledLabelOffset:CGSizeZero];
    }
    
    return _aboutButtonStyle;
}


+ (ButtonStyle *)airportCodesButtonStyle {
    if (!_airportCodesButtonStyle) {
        _airportCodesButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil 
                                                        disabledLabelStyle:nil
                                                           backgroundColor:nil
                                                                   upImage:[[UIImage imageNamed:@"small_button_white_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)]
                                                                 downImage:[[UIImage imageNamed:@"small_button_white_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)] 
                                                             disabledImage:nil 
                                                                 iconImage:[UIImage imageNamed:@"lookup" withColor:[UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f]
                                                                                   shadowColor:[UIColor whiteColor] 
                                                                                  shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                                                    shadowBlur:1.0f]
                                                         iconDisabledImage:nil
                                                                iconOrigin:CGPointMake(8.0f, 8.0f)
                                                             labelInsets:UIEdgeInsetsZero
                                                         downLabelOffset:CGSizeMake(0.0f, 1.0f)
                                                     disabledLabelOffset:CGSizeZero];
    }
    
    return _airportCodesButtonStyle;
}


+ (ButtonStyle *)airportCodesLabelButtonStyle {
    if (!_airportCodesLabelButtonStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:13.5f]  
                                                         color:[UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor whiteColor]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                       backgroundColor:nil
                                                             alignment:UITextAlignmentLeft 
                                                         lineBreakMode:UILineBreakModeTailTruncation];
        
        
        _airportCodesLabelButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle 
                                                             disabledLabelStyle:nil
                                                                backgroundColor:nil
                                                                        upImage:nil
                                                                      downImage:nil
                                                                  disabledImage:nil 
                                                                      iconImage:nil
                                                              iconDisabledImage:nil
                                                                     iconOrigin:CGPointZero
                                                                    labelInsets:UIEdgeInsetsMake(5.0f, 33.5f, 5.0f, 40.0f)
                                                                downLabelOffset:CGSizeZero
                                                            disabledLabelOffset:CGSizeZero];
    }
    
    return _airportCodesLabelButtonStyle;
}


+ (LabelStyle *)flightFieldLabelStyle {
    if (!_flightFieldLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:23.0f] 
                                                         color:[UIColor colorWithRed:107.0f/255.0f green:157.0f/255.0f blue:178.0f/255.0f alpha:1.0f]
                                                   shadowColor:nil 
                                                  shadowOffset:CGSizeZero 
                                                    shadowBlur:0.0f];
        
        _flightFieldLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                       backgroundColor:nil 
                                                             alignment:UITextAlignmentLeft 
                                                         lineBreakMode:UILineBreakModeClip];
        
    }
    
    return _flightFieldLabelStyle;
}


+ (LabelStyle *)flightFieldTextStyle {
    if (!_flightFieldTextStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:23.0f]
                                                         color:[UIColor colorWithRed:51.0/255.0f green:51.0/255.0f blue:51.0/255.0f alpha:1.0f]
                                                   shadowColor:nil 
                                                  shadowOffset:CGSizeZero 
                                                    shadowBlur:0.0f];
        
        _flightFieldTextStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil 
                                                            alignment:UITextAlignmentLeft 
                                                        lineBreakMode:UILineBreakModeClip];
        
    }
    
    return _flightFieldTextStyle;
}


+ (LabelStyle *)noAirlineResultsLabel {
    if (!_airlineNoResultsLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:20.0f]
                                                         color:[UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f]
                                                   shadowColor:nil 
                                                  shadowOffset:CGSizeZero 
                                                    shadowBlur:0.0f];
        
        _airlineNoResultsLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil 
                                                            alignment:UITextAlignmentCenter 
                                                        lineBreakMode:UILineBreakModeClip];
        
    }
    
    return _airlineNoResultsLabelStyle;
}

@end
