//
//  UIBarButtonItem+JLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 5/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "UIBarButtonItem+JLExtensions.h"
#import "JLStyles.h"

@implementation UIBarButtonItem (JLExtensions)

+ (void)initialize {
    [super initialize];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
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
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: buttonStyle.labelStyle.textStyle.font,
                                                               UITextAttributeTextColor: buttonStyle.labelStyle.textStyle.color,
                                                               UITextAttributeTextShadowColor: buttonStyle.labelStyle.textStyle.shadowColor,
                                                               UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:buttonStyle.labelStyle.textStyle.shadowOffset]}
                                                    forState:UIControlStateNormal];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: buttonStyle.disabledLabelStyle.textStyle.font,
                                                               UITextAttributeTextColor: buttonStyle.disabledLabelStyle.textStyle.color,
                                                               UITextAttributeTextShadowColor: buttonStyle.disabledLabelStyle.textStyle.shadowColor,
                                                               UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:buttonStyle.disabledLabelStyle.textStyle.shadowOffset]}
                                                    forState:UIControlStateDisabled];

        [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f)
                                                   forBarMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-2.0f, 2.0f) 
                                                             forBarMetrics:UIBarMetricsDefault];
    } else {
        // Text styles
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: [JLStyles sansSerifLightBoldOfSize:18.0f]}
                                                    forState:UIControlStateNormal];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: [JLStyles sansSerifLightBoldOfSize:18.0f]}
                                                    forState:UIControlStateDisabled];
    }
}

@end
