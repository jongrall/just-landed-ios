//
//  JLStatusLabel.m
//  Just Landed
//
//  Created by Jon Grall on 4/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLStatusLabel.h"
#import "JLStyles.h"

@interface JLStatusLabel () {
    __strong UIColor *_shadowColor;
}

@end


@implementation JLStatusLabel

@synthesize status;

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame status:(FlightStatus)aStatus {
    self = [super initWithLabelStyle:aStyle frame:aFrame];
    
    if (self) {
        [self setStatus:aStatus];
    }
    
    return self;
}


- (void)setStatus:(FlightStatus)newStatus {
    _shadowColor = [JLStyles labelShadowColorForStatus:newStatus];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    // Background color
    [[self.style backgroundColor] set];
    CGContextFillRect(context, rect);
    
    TextStyle *textStyle = [self.style textStyle];
    
    // Shadow
    if (_shadowColor) {
        CGContextSetShadowWithColor(context, [textStyle shadowOffset], [textStyle shadowBlur], [_shadowColor CGColor]);
    }
    
    // Draw the text
    [[textStyle color] set];
    [self.text drawInRect:rect 
            withFont:[textStyle font] 
       lineBreakMode:[self.style lineBreakMode] 
           alignment:[self.style alignment]];
}

@end
