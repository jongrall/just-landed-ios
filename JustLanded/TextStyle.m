//
//  TextStyle.m
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;
#import "TextStyle.h"

@interface TextStyle ()

// Redefine as readwrite
@property (strong, readwrite, nonatomic) UIFont *font;
@property (strong, readwrite, nonatomic) UIColor *color;
@property (strong, readwrite, nonatomic) UIColor *shadowColor;
@property (readwrite, nonatomic) CGSize shadowOffset;
@property (readwrite, nonatomic) CGFloat shadowBlur;

@end


@implementation TextStyle

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
        self.font = font;
        self.color = aColor;
        self.shadowColor = aShadowColor;
        self.shadowOffset = offset;
        self.shadowBlur = blur;
    }
    
    return self;
}

@end
