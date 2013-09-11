//
//  UIView+JLExtensions.m
//  JustLanded
//
//  Created by Jon Grall on 8/22/13.
//  Copyright (c) 2013 Little Details LLC. All rights reserved.
//

#import "UIView+JLExtensions.h"

@implementation UIView (JLExtensions)

- (UIView *)findViewOfKindInViewHierarchy:(Class)viewClass {
    NSParameterAssert([viewClass isSubclassOfClass:[UIView class]]);

    UIView *foundView = nil;

    for (UIView *aView in self.subviews) {
        if ([aView isKindOfClass:[viewClass class]]) {
            foundView = aView;
            break;
        }
        else {
            foundView = [aView findViewOfKindInViewHierarchy:viewClass];
        }
    }

    return foundView;
}

@end
