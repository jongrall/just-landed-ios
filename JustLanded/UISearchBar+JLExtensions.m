//
//  UISearchBar+JLExtensions.m
//  JustLanded
//
//  Created by Jon Grall on 8/22/13.
//  Copyright (c) 2013 Little Details LLC. All rights reserved.
//

#import "UISearchBar+JLExtensions.h"

@implementation UISearchBar (JLExtensions)

+ (void)initialize {
    [super initialize];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        UIImage *bgImage = [[UIImage imageNamed:@"query_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f)];
        [[UISearchBar appearance] setBackgroundImage:bgImage];
        UIImage *fieldBg = [[UIImage imageNamed:@"query_field"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
        [[UISearchBar appearance] setSearchFieldBackgroundImage:fieldBg forState:UIControlStateNormal];
        [[UISearchBar appearance] setSearchTextPositionAdjustment:UIOffsetMake(0.0f, 2.0f)];
    } else {
        [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleProminent];
        [[UISearchBar appearance] setSearchTextPositionAdjustment:UIOffsetMake(0.0f, 2.0f)];
    }
}

@end
