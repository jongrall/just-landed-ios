//
//  UINavigationBar+JLExtensions.m
//  JustLanded
//
//  Created by Jon Grall on 5/6/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "UINavigationBar+JLExtensions.h"

@implementation UINavigationBar (JLExtensions)

+ (void)initialize {
    [super initialize];
    
    // Custom navbar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg"] 
                                       forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.5f
                                                       forBarMetrics:UIBarMetricsDefault];
    
    TextStyle *navTitleStyle = [JLStyles navbarTitleStyle];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          navTitleStyle.font, UITextAttributeFont,
                                                          navTitleStyle.color, UITextAttributeTextColor,
                                                          navTitleStyle.shadowColor, UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:navTitleStyle.shadowOffset], UITextAttributeTextShadowOffset, 
                                                          nil]];
}

@end
