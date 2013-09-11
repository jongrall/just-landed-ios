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
    if (iOS_6_OrEarlier()) {
        UIImage *bgImage = [[UIImage imageNamed:@"query_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f)];
        [[UISearchBar appearance] setBackgroundImage:bgImage];
        UIImage *fieldBg = [[UIImage imageNamed:@"query_field"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
        [[UISearchBar appearance] setSearchFieldBackgroundImage:fieldBg forState:UIControlStateNormal];
        [[UISearchBar appearance] setSearchTextPositionAdjustment:UIOffsetMake(0.0f, 2.0f)];
    }
}


- (void)adoptJustLandedStyle {
    if (!iOS_6_OrEarlier()) {
        UIImage *bgImage = [[UIImage imageNamed:@"query_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f)];
        [self setBackgroundImage:bgImage];
        UIImage *fieldBg = [[UIImage imageNamed:@"query_field"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
        [self setSearchFieldBackgroundImage:fieldBg forState:UIControlStateNormal];
        [self setSearchTextPositionAdjustment:UIOffsetMake(7.0f, 2.0f)];
        [self setTintColor:[JLLookupStyles lookupFieldTintColor]];
    }

    UITextField *searchField = (UITextField *)[self findViewOfKindInViewHierarchy:[UITextField class]];
    [searchField setFont:[JLStyles sansSerifLightBoldOfSize:18.0f]];
    searchField.textColor = [JLLookupStyles flightFieldTextStyle].textStyle.color;
}
@end
