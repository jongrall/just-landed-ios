//
//  JLLookupStyles.m
//  Just Landed
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLookupStyles.h"
#import "TextStyle.h"

@implementation JLLookupStyles

+ (CGRect)logoFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{38.0f, 52.0f}, {255.0f, 43.0f}};
    }
    else {
        return (CGRect) {{38.0f, 32.0f}, {255.0f, 43.0f}};
    }
}


+ (CGRect)lookupButtonFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{12.0f, 199.0f}, {296.0f, 56.0f}};
    }
    else {
        return (CGRect) {{12.0f, 179.0f}, {296.0f, 56.0f}};
    }
}


+ (CGRect)airportCodesLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{20.0f, 272.0f}, {280.0f, 30.0f}};
    }
    else {
        return (CGRect) {{20.0f, 204.0f}, {280.0f, 30.0f}};
    }
}


+ (CGRect)airportCodesButtonFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{229.0f, 269.0f}, {33.0f, 34.0f}};
    }
    else {
        return (CGRect) {{229.0f, 201.0f}, {33.0f, 34.0f}};
    }
}


+ (CGRect)airlineNoResultsLabelFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{20.0f, 101.0f}, {280.0f, 40.0f}};
    }
    else {
        return (CGRect) {{20.0f, 57.0f}, {280.0f, 40.0f}};
    }
}


+ (CGRect)aboutButtonFrame {
    return (CGRect) {{271.0f, 0.0f}, {49.0f, 49.0f}};
}


+ (CGRect)lookupInputFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{14.0f, 137.0f}, {292.0f, 49.0f}};
    }
    else {
        return (CGRect) {{14.0f, 117.0f}, {292.0f, 49.0f}};
    }
}


+ (CGRect)lookupTextFieldFrame {
    return (CGRect) {{0.0f, 0.0f}, {288.0f, 49.0f}};
}


+ (CGRect)lookupLabelFrame {
    return (CGRect) {{0.0f, 0.0f}, {150.0f, 49.0f}};
}


+ (CGPoint)lookupSeparatorOrigin {
    return (CGPoint) {113.5f , 12.0f};
}


+ (CGRect)lookupLabelTextFrame {
    return (CGRect) {{0.0f, 15.0f}, {150.0f, 49.0f}};
}


+ (CGRect)lookupFieldFrame {
    return (CGRect) {{0.0f, 0.0f}, {100.0f, 49.0f}};
}


+ (CGRect)lookupSpinnerFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{103.0f, 318.0f}, {114.0f, 115.0f}};
    }
    else {
        return (CGRect) {{103.0f, 278.0f}, {114.0f, 115.0f}};
    }
}


+ (CGRect)cloudLayerFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 150.0f}, {320.0f, 340.0f}};
    }
    else {
        return (CGRect) {{0.0f, 98.0f}, {320.0f, 340.0f}};
    }
    
}


+ (CGRect)cloudFooterFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 490.0f}, {320.0f, 58.0f}};
    }
    else {
        return (CGRect) {{0.0f, 438.0f}, {320.0f, 22.0f}};
    }
}


+ (CGRect)airplaneFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 105.0f}, {320.0f, 22.0f}};
    }
    else {
        return (CGRect) {{0.0f, 85.0f}, {320.0f, 22.0f}};
    }
}


+ (CGRect)resultsTableFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{16.0f, 207.0f}, {288.0f, 324.0f}};
    }
    else {
        return (CGRect) {{16.0f, 187.0f}, {288.0f, 257.0f}};
    }
}


+ (CGRect)resultsTableContainerFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{15.0f, 205.0f}, {290.0f, 328.0f}};
    }
    else {
       return (CGRect) {{15.0f, 185.0f}, {290.0f, 261.0f}}; 
    }
}


+ (ButtonStyle *)lookupButtonStyle {
    static ButtonStyle *sLookupButtonStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        ButtonStyle *defaultStyle = [JLStyles defaultButtonStyle];
        
        // Override text alignment
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:defaultStyle.labelStyle.textStyle 
                                                       backgroundColor:defaultStyle.labelStyle.backgroundColor
                                                             alignment:NSTextAlignmentLeft
                                                         lineBreakMode:defaultStyle.labelStyle.lineBreakMode];
        LabelStyle *disabledStyle = [[LabelStyle alloc] initWithTextStyle:defaultStyle.disabledLabelStyle.textStyle
                                                          backgroundColor:defaultStyle.disabledLabelStyle.backgroundColor
                                                                alignment:NSTextAlignmentLeft 
                                                            lineBreakMode:defaultStyle.disabledLabelStyle.lineBreakMode];
        
        // Create from the default style and ovverride the icon and insets
        sLookupButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle
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
    });
    
    return sLookupButtonStyle;
}


+ (ButtonStyle *)aboutButtonStyle {
    static ButtonStyle *sAboutButtonStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        sAboutButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil 
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
    });
    
    return sAboutButtonStyle;
}


+ (ButtonStyle *)airportCodesButtonStyle {
    static ButtonStyle *sAirportCodesButtonStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        sAirportCodesButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil
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
    });
    
    return sAirportCodesButtonStyle;
}


+ (ButtonStyle *)airportCodesLabelButtonStyle {
    static ButtonStyle *sAirportCodesLabelButtonStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:13.5f]  
                                                         color:[UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor whiteColor]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                       backgroundColor:nil
                                                             alignment:NSTextAlignmentLeft 
                                                         lineBreakMode:NSLineBreakByTruncatingTail];
        
        
        sAirportCodesLabelButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle 
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
    });
    
    return sAirportCodesLabelButtonStyle;
}


+ (LabelStyle *)flightFieldLabelStyle {
    static LabelStyle *sFlightFieldLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:23.0f]
                                                         color:[UIColor colorWithRed:107.0f/255.0f green:157.0f/255.0f blue:178.0f/255.0f alpha:1.0f]
                                                   shadowColor:nil 
                                                  shadowOffset:CGSizeZero 
                                                    shadowBlur:0.0f];
        
        sFlightFieldLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                       backgroundColor:nil 
                                                             alignment:NSTextAlignmentLeft 
                                                         lineBreakMode:NSLineBreakByClipping];
        
    });
    
    return sFlightFieldLabelStyle;
}


+ (LabelStyle *)flightFieldTextStyle {
    static LabelStyle *sFlightFieldTextStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:23.0f]
                                                         color:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:nil 
                                                  shadowOffset:CGSizeZero 
                                                    shadowBlur:0.0f];
        
        sFlightFieldTextStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil 
                                                            alignment:NSTextAlignmentLeft 
                                                        lineBreakMode:NSLineBreakByClipping];
        
    });
    
    return sFlightFieldTextStyle;
}


+ (LabelStyle *)flightFieldErrorTextStyle {
    static LabelStyle *sFlightFieldErrorTextStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:23.0f]
                                                         color:[UIColor colorWithRed:215.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                                                   shadowColor:nil
                                                  shadowOffset:CGSizeZero
                                                    shadowBlur:0.0f];
        
        sFlightFieldErrorTextStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:NSTextAlignmentLeft
                                                        lineBreakMode:NSLineBreakByClipping];
        
    });
    
    return sFlightFieldErrorTextStyle;
}


+ (LabelStyle *)noAirlineResultsLabel {
    static LabelStyle *sAirlineNoResultsLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:20.0f]
                                                         color:[UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f]
                                                   shadowColor:nil 
                                                  shadowOffset:CGSizeZero 
                                                    shadowBlur:0.0f];
        
        sAirlineNoResultsLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil 
                                                            alignment:NSTextAlignmentCenter 
                                                        lineBreakMode:NSLineBreakByClipping];
        
    });
    
    return sAirlineNoResultsLabelStyle;
}

@end
