//
//  LabelStyle.m
//  JustLanded
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "LabelStyle.h"

@interface LabelStyle () {
    __strong TextStyle *_textStyle;
    __strong UIColor *_backgroundColor;
    UITextAlignment _alignment;
    UILineBreakMode _lineBreakMode;
}

@end


@implementation LabelStyle

@synthesize textStyle=_textStyle;
@synthesize backgroundColor=_backgroundColor;
@synthesize alignment=_alignment;
@synthesize lineBreakMode=_lineBreakMode;

- (id)init {
    return [self initWithTextStyle:[[TextStyle alloc] init]
                   backgroundColor:nil
                         alignment:UITextAlignmentLeft
                     lineBreakMode:UILineBreakModeTailTruncation];
}


- (id)initWithTextStyle:(TextStyle *)style
        backgroundColor:(UIColor *)aColor
              alignment:(UITextAlignment)anAlignment
          lineBreakMode:(UILineBreakMode)aMode {
    NSAssert(style != nil, @"LabelStyle requires a TextStyle.");
    
    self = [super init];
    
    if (self) {
        _textStyle = style;
        _alignment = anAlignment;
        _lineBreakMode = aMode;
        
        if (aColor != nil) {
            _backgroundColor = aColor;
        }
        else {
            _backgroundColor = [UIColor clearColor];
        }
    }
    
    return self;
}

@end
