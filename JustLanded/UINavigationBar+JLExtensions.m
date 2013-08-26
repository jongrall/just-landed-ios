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
    if (iOS_6_OrEarlier()) {
        TextStyle *navTitleStyle = [JLStyles navbarTitleStyle];
        [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:navTitleStyle.font,
                                                               UITextAttributeTextColor:navTitleStyle.color,
                                                               UITextAttributeTextShadowColor:navTitleStyle.shadowColor,
                                                               UITextAttributeTextShadowOffset:[NSValue valueWithCGSize:navTitleStyle.shadowOffset]}];
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.5f forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0, 0.0, 37.0, 0.0)]
                                           forBarMetrics:UIBarMetricsDefault];
    }
}


- (void)adoptJustLandedStyle {
    // Custom navbar
    if (!iOS_6_OrEarlier()) {
        TextStyle *navTitleStyle = [JLStyles navbarTitleStyle];
        [self setTitleTextAttributes:@{UITextAttributeFont:navTitleStyle.font,
                                       UITextAttributeTextColor:navTitleStyle.color,
                                       UITextAttributeTextShadowColor:navTitleStyle.shadowColor,
                                       UITextAttributeTextShadowOffset:[NSValue valueWithCGSize:navTitleStyle.shadowOffset]}];
        [self setTitleVerticalPositionAdjustment:2.0f forBarMetrics:UIBarMetricsDefault];
        [self setBackgroundImage:[UIImage imageNamed:@"nav_bg_newstyle"]
                                           forBarMetrics:UIBarMetricsDefault];
        [self setTintColor:[UIColor whiteColor]];
        [self setBarStyle:UIBarStyleBlackOpaque];
    }

    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowColor = [[UIColor clearColor] CGColor];
    self.layer.shadowOpacity = 0.0f;
    self.layer.shadowRadius = 0.0f;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:[self bounds]] CGPath]; //Optimization avoids offscreen render pass
}

@end
