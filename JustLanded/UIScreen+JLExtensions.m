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

@end
