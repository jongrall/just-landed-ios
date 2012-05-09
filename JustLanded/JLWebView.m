//
//  JLWebView.m
//  JustLanded
//
//  Created by Jon Grall on 5/9/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLWebView.h"
#import <QuartzCore/QuartzCore.h>

@interface JLWebView () {
    __strong UIBezierPath *_clipPath;
}

@end


@implementation JLWebView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _clipPath = [self pathForFrame:frame];
    }
    
    return self;
}


- (void)setFrame:(CGRect)aFrame {
    [super setFrame:aFrame];
    _clipPath = [self pathForFrame:aFrame];
    [self setNeedsDisplay];
}


- (UIBezierPath *)pathForFrame:(CGRect)aFrame {
    return [UIBezierPath bezierPathWithRoundedRect:aFrame 
                                 byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight 
                                       cornerRadii:CGSizeMake(6.0f, 6.0f)];
}

- (void)drawRect:(CGRect)rect {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [_clipPath CGPath];
    self.scrollView.layer.mask = maskLayer;
    [super drawRect:rect];
}

@end
