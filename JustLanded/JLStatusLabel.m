//
//  JLStatusLabel.m
//  Just Landed
//
//  Created by Jon Grall on 4/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLStatusLabel.h"
#import "JLStyles.h"

@interface JLStatusLabel ()

@property (strong, nonatomic) UIColor *shadowColor_;

@end


@implementation JLStatusLabel

@synthesize status = status_;
@synthesize shadowColor_;

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame status:(FlightStatus)aStatus {
    self = [super initWithLabelStyle:aStyle frame:aFrame];
    
    if (self) {
        [self setStatus:aStatus];
    }
    
    return self;
}


- (void)setStatus:(FlightStatus)newStatus {
    status_ = newStatus;
    self.shadowColor_ = [JLStyles labelShadowColorForStatus:newStatus];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    LabelStyle *style_ = self.style;
    
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    // Background color
    [style_.backgroundColor set];
    CGContextFillRect(context, rect);
    
    TextStyle *textStyle = style_.textStyle;
    
    // Shadow
    if (shadowColor_) {
        CGContextSetShadowWithColor(context, textStyle.shadowOffset, textStyle.shadowBlur, [shadowColor_ CGColor]);
    }
    
    // Draw the text
    [textStyle.color set];
    [self.text drawInRect:rect
                 withFont:textStyle.font
            lineBreakMode:style_.lineBreakMode
                alignment:style_.alignment];
}

@end
