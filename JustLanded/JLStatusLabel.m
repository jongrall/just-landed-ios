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
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    // Background color
    [self.style.backgroundColor set];
    CGContextFillRect(context, rect);
    
    TextStyle *textStyle = self.style.textStyle;
    
    // Shadow
    if (self.shadowColor_) {
        CGContextSetShadowWithColor(context, textStyle.shadowOffset, textStyle.shadowBlur, [self.shadowColor_ CGColor]);
    }
    
    // Draw the text
    [textStyle.color set];
    [self.text drawInRect:rect 
            withFont:textStyle.font
       lineBreakMode:self.style.lineBreakMode
           alignment:self.style.alignment];
}

@end
