//
//  UIScreen+JLExtensions.m
//  JustLanded
//
//  Created by Jon on 9/26/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "UIScreen+JLExtensions.h"

@implementation UIScreen (JLExtensions)

+ (BOOL)isMainScreenWide {
    static BOOL sWideScreen;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        sWideScreen = fabs((double)[[self mainScreen] bounds].size.height - (double)568) < DBL_EPSILON;
    });
    
    return sWideScreen;
}


+ (CGRect)mainContentViewFrame {
    CGFloat statusBarHeight = 20.0f; // Assumed fixed
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    if (iOS_6_OrEarlier()) {
        return CGRectMake(0.0f, 0.0f, screenBounds.size.width, screenBounds.size.height - statusBarHeight);
    } else {
        return CGRectMake(0.0f, statusBarHeight, screenBounds.size.width, screenBounds.size.height - statusBarHeight);
    }
}

@end
