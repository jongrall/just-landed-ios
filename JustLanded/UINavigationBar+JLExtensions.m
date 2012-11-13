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
    
    // Custom navbar
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0, 0.0, 37.0, 0.0)]
                                       forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.5f
                                                       forBarMetrics:UIBarMetricsDefault];
    
    TextStyle *navTitleStyle = [JLStyles navbarTitleStyle];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont: navTitleStyle.font,
                                                          UITextAttributeTextColor: navTitleStyle.color,
                                                          UITextAttributeTextShadowColor: navTitleStyle.shadowColor,
                                                          UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:navTitleStyle.shadowOffset]}];
}

@end
