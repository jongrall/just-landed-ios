//
//  JLLabel.m
//  Just Landed
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLabel.h"

@interface JLLabel ()

// Redefine as readwrite
@property (strong, readwrite, nonatomic) LabelStyle *style;

@end


@implementation JLLabel

@synthesize text = text_;
@synthesize style = style_;

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    if (self) {
        style_ = aStyle;
        self.opaque = NO;
        text_ = @"";
    }

    return self;
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    // Background color
    if (style_.backgroundColor) {
        [style_.backgroundColor set];
        CGContextFillRect(context, rect);
    }
    
    TextStyle *textStyle = style_.textStyle;
    
    // Shadow
    if (textStyle.shadowColor) {
        CGContextSetShadowWithColor(context, textStyle.shadowOffset, textStyle.shadowBlur, [textStyle.shadowColor CGColor]);
    }
    
    // Draw the text
    [textStyle.color set];
    [text_ drawInRect:rect
            withFont:textStyle.font
       lineBreakMode:style_.lineBreakMode
           alignment:style_.alignment];
    
    [super drawRect:rect];
}


- (void)setText:(NSString *)someText {
    if (text_ != someText) {
        text_ = [someText copy];
        [self setNeedsDisplay];
    }
}

@end
