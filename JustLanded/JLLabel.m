//
//  JLLabel.m
//  JustLanded
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLLabel.h"

@interface JLLabel () {
    __strong LabelStyle *_style;
}

@end


@implementation JLLabel

@synthesize text;
@synthesize style=_style;

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    if (self) {
        _style = aStyle;
        [self setOpaque:NO];
        self.text = @"";
    }

    return self;
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    // Background color
    [[_style backgroundColor] set];    
    CGContextFillRect(context, rect);
    
    TextStyle *textStyle = [_style textStyle];
    
    // Shadow
    if ([textStyle shadowColor]) {
        CGContextSetShadowWithColor(context, [textStyle shadowOffset], [textStyle shadowBlur], [[textStyle shadowColor] CGColor]);
    }
    
    // Draw the text
    [[textStyle color] set];
    [text drawInRect:rect 
            withFont:[textStyle font] 
       lineBreakMode:[_style lineBreakMode] 
           alignment:[_style alignment]];
    
    [super drawRect:rect];
}


- (void)setText:(NSString *)someText {
    if (text != someText) {
        text = someText;
        [self setNeedsDisplay];
    }
}

@end
