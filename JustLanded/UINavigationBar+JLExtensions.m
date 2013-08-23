//
//  UINavigationBar+JLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 5/6/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "UINavigationBar+JLExtensions.h"

@implementation UINavigationBar (JLExtensions)

+ (void)initialize {
    [super initialize];
    TextStyle *navTitleStyle = [JLStyles navbarTitleStyle];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Custom navbar
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0, 0.0, 37.0, 0.0)]
                                           forBarMetrics:UIBarMetricsDefault];

        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.5f
                                                           forBarMetrics:UIBarMetricsDefault];

        [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont: navTitleStyle.font,
                                                               UITextAttributeTextColor: navTitleStyle.color,
                                                               UITextAttributeTextShadowColor: navTitleStyle.shadowColor,
                                                               UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:navTitleStyle.shadowOffset]}];
    } else {
        [[UINavigationBar appearance] setTintColor:[JLLookupStyles flightFieldLabelStyle].textStyle.color];
        [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont: navTitleStyle.font,
                                                               UITextAttributeTextColor: [JLLookupStyles flightFieldTextStyle].textStyle.color}];
    }
}

@end
