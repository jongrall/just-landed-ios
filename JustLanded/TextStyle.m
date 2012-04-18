//
//  TextStyle.m
//  JustLanded
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextStyle.h"

@interface TextStyle () {
    __strong UIFont *_font;
    __strong UIColor *_color;
    __strong UIColor *_shadowColor;
    CGSize _shadowOffset;
    CGFloat _shadowBlur;
}

@end


@implementation TextStyle

@synthesize font=_font;
@synthesize color=_color;
@synthesize shadowColor=_shadowColor;
@synthesize shadowOffset=_shadowOffset;
@synthesize shadowBlur=_shadowBlur;


- (id)init {
    return [self initWithFont:[UIFont systemFontOfSize:14.0f]
                        color:[UIColor whiteColor]
                  shadowColor:nil
                 shadowOffset:CGSizeZero
                   shadowBlur:0.0f];
}            

- (id)initWithFont:(UIFont *)font
             color:(UIColor *)aColor
       shadowColor:(UIColor *)aShadowColor
      shadowOffset:(CGSize)offset
        shadowBlur:(CGFloat)blur {
    NSAssert(font != nil, @"Text style requires a font.");
    NSAssert(aColor != nil, @"Text style requires a color.");
    
    self = [super init];
    
    if (self) {
        _font = font;
        _color = aColor;
        _shadowColor = aShadowColor;
        _shadowOffset = offset;
        _shadowBlur = blur;
    }
    
    return self;
}

@end
