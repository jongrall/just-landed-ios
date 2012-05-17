//
//  JLLookupStyles.m
//  JustLanded
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLLookupStyles.h"

CGRect const LOGO_FRAME = {35.5f, 33.5f, 248.0f, 40.0f};
CGRect const LOOKUP_BUTTON_FRAME = {12.0f, 179.5f, 296.0f, 56.0f};
CGRect const ABOUT_BUTTON_FRAME = {271.0f, 0.0f, 49.0f, 49.0f};
CGRect const LOOKUP_INPUT_FRAME = {14.0f, 117.5f, 292.0f, 49.0f};
CGRect const LOOKUP_TEXTFIELD_FRAME = {0.0f, 0.0f, 288.0f, 49.0f};
CGRect const LOOKUP_LABEL_FRAME = {0.0f, 0.0f, 150.0f, 49.0f};
CGPoint const LOOKUP_SEPARATOR_ORIGIN = {113.5f , 12.0f};
CGRect const LOOKUP_LABEL_TEXT_FRAME = {0.0f, 15.5f, 150.0f, 49.0f};
CGRect const LOOKUP_FIELD_FRAME = {0.0f, 0.0f, 100.0f, 49.0f};
CGRect const CLOUD_LAYER_FRAME = {0.0f, 168.0f, 320.0f, 30.0f};
CGRect const CLOUD_FOOTER_FRAME = {0.0f, 198.0f, 320.0f, 262.0f};
CGRect const RESULTS_TABLE_FRAME = {16.0f, 187.0f, 288.0f, 257.0f};
CGRect const RESULTS_TABLE_CONTAINER_FRAME = {15.0f, 185.0f, 290.0f, 261.0f};


@implementation JLLookupStyles

static ButtonStyle *_lookupButtonStyle;
static ButtonStyle *_aboutButtonStyle;
static LabelStyle *_flightFieldLabelStyle;
static LabelStyle *_flightFieldTextStyle;


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
                                                                            shadowOffset:defaultStyle.labelStyle.textStyle.shadowOffset
                                                                              shadowBlur:defaultStyle.labelStyle.textStyle.shadowBlur]
                                                   iconDisabledImage:[UIImage imageNamed:@"lookup_glass" 
                                                                               withColor:defaultStyle.disabledLabelStyle.textStyle.color
                                                                             shadowColor:defaultStyle.disabledLabelStyle.textStyle.shadowColor 
                                                                            shadowOffset:defaultStyle.disabledLabelStyle.textStyle.shadowOffset
                                                                              shadowBlur:defaultStyle.disabledLabelStyle.textStyle.shadowBlur]
                                                          iconOrigin:CGPointMake(73.0f, 11.5f)
                                                         labelInsets:UIEdgeInsetsMake(-3.5f, 104.0f, 0.0f, 20.0f) 
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

@end
