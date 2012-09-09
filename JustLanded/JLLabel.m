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

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    if (self) {
        self.style = aStyle;
        self.opaque = NO;
        self.text = @"";
    }

    return self;
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    // Background color
    if (self.style.backgroundColor) {
        [self.style.backgroundColor set];
        CGContextFillRect(context, rect);
    }
    
    TextStyle *textStyle = self.style.textStyle;
    
    // Shadow
    if (textStyle.shadowColor) {
        CGContextSetShadowWithColor(context, textStyle.shadowOffset, textStyle.shadowBlur, [textStyle.shadowColor CGColor]);
    }
    
    // Draw the text
    [textStyle.color set];
    [self.text drawInRect:rect
            withFont:textStyle.font
       lineBreakMode:self.style.lineBreakMode
           alignment:self.style.alignment];
    
    [super drawRect:rect];
}


- (void)setText:(NSString *)someText {
    if (text_ != someText) {
        text_ = [someText copy];
        [self setNeedsDisplay];
    }
}

@end
