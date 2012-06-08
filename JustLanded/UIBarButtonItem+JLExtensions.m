//
//  UIBarButtonItem+JLExtensions.m
//  Just Landed LLC
//
//  Created by Jon Grall on 5/4/12.
//  Copyright 2012 Just Landed LLC. All rights reserved.
//

#import "UIBarButtonItem+JLExtensions.h"
#import "JLStyles.h"

@implementation UIBarButtonItem (JLExtensions)

+ (void)initialize {
    [super initialize];
    ButtonStyle *buttonStyle = [JLStyles navbarButtonStyle];
    ButtonStyle *backButtonStyle = [JLStyles navbarBackButtonStyle];
    
    // Normal button background images
    [[UIBarButtonItem appearance] setBackgroundImage:buttonStyle.upImage 
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:buttonStyle.downImage 
                                            forState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:buttonStyle.downImage 
                                            forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonStyle.upImage 
                                                      forState:UIControlStateNormal 
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonStyle.downImage 
                                                      forState:UIControlStateSelected 
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonStyle.downImage 
                                                      forState:UIControlStateHighlighted 
                                                    barMetrics:UIBarMetricsDefault];
    
    // Text styles
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    buttonStyle.labelStyle.textStyle.font, UITextAttributeFont,
                                                    buttonStyle.labelStyle.textStyle.color, UITextAttributeTextColor,
                                                    buttonStyle.labelStyle.textStyle.shadowColor, UITextAttributeTextShadowColor,
                                                    [NSValue valueWithCGSize:buttonStyle.labelStyle.textStyle.shadowOffset], UITextAttributeTextShadowOffset, 
                                                    nil] 
                                          forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    buttonStyle.disabledLabelStyle.textStyle.font, UITextAttributeFont,
                                                    buttonStyle.disabledLabelStyle.textStyle.color, UITextAttributeTextColor,
                                                    buttonStyle.disabledLabelStyle.textStyle.shadowColor, UITextAttributeTextShadowColor,
                                                    [NSValue valueWithCGSize:buttonStyle.disabledLabelStyle.textStyle.shadowOffset], UITextAttributeTextShadowOffset, 
                                                    nil] 
                                          forState:UIControlStateDisabled];
    
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f)
                                               forBarMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-2.0f, 2.0f) 
                                                         forBarMetrics:UIBarMetricsDefault];
}

@end
