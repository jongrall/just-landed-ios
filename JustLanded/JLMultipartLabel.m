//
//  JLMultipartLabel.m
//  Just Landed
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMultipartLabel.h"
#import "LabelStyle.h"

@implementation JLMultipartLabel

@synthesize parts;
@synthesize styles;
@synthesize offsets;

- (id)initWithLabelStyles:(NSArray *)someStyles frame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    if (self) {
        self.styles = someStyles;
        self.opaque = NO;
        
        NSMutableArray *labelParts = [NSMutableArray array];
        NSMutableArray *labelOffsets = [NSMutableArray array];
        
        for (NSUInteger i=0; i < [someStyles count]; i++) {
            [labelParts addObject:@""];
            [labelOffsets addObject:[NSValue valueWithCGSize:CGSizeZero]];
        }
        
        self.parts = labelParts;
        self.offsets = offsets;
    }
    
    return self;
}


- (void)setParts:(NSArray *)newParts {
    parts = newParts;
    [self setNeedsDisplay];
}


- (void)setOffsets:(NSArray *)newOffsets {
    offsets = newOffsets;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGRect remainingRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    for (NSUInteger i = 0; i < [parts count]; i++) {
        NSString *nextPart = [parts objectAtIndex:i];
        
        CGContextSaveGState(context);
        
        // Get the next offset, guard against programmer error
        CGSize nextOffset = CGSizeZero;
        if (offsets) {
            nextOffset = ([offsets count] > i) ? [[offsets objectAtIndex:i] CGSizeValue] : [[offsets lastObject] CGSizeValue];
        }
        
        LabelStyle *nextStyle;
        
        // Get the next style, guard against programmer error
        if (styles) {
            nextStyle = ([styles count] > i) ? [styles objectAtIndex:i] : [styles lastObject];
        }
        else {
            break; // Unrecoverable, we need at least one text style
        }
        
        // Background color
        [[nextStyle backgroundColor] set];    
        CGContextFillRect(context, rect);
        
        TextStyle *textStyle = [nextStyle textStyle];
        
        // Shadow
        if ([textStyle shadowColor]) {
            CGContextSetShadowWithColor(context, [textStyle shadowOffset], [textStyle shadowBlur], [[textStyle shadowColor] CGColor]);
        }
        
        // Calculate the rectangle to draw in
        CGRect offsetRemainingRect = CGRectMake(remainingRect.origin.x + nextOffset.width,
                                                remainingRect.origin.y + nextOffset.height,
                                                remainingRect.size.width - nextOffset.width,
                                                remainingRect.size.height - nextOffset.height);
        
        // Draw the next piece of text
        [[textStyle color] set];
        [nextPart drawInRect:offsetRemainingRect 
                    withFont:[textStyle font] 
               lineBreakMode:[nextStyle lineBreakMode] 
                   alignment:[nextStyle alignment]];
        
        // Calculate the size of the remaining rectangle for the next part of the label
        CGSize textSize = [nextPart sizeWithFont:[textStyle font] 
                               constrainedToSize:offsetRemainingRect.size 
                                   lineBreakMode:[nextStyle lineBreakMode]];
        
        remainingRect = CGRectMake(remainingRect.origin.x + textSize.width + nextOffset.width,
                                   remainingRect.origin.y,
                                   remainingRect.size.width - textSize.width - nextOffset.width,
                                   remainingRect.size.height);
        
        CGContextRestoreGState(context);
    }
    
    [super drawRect:rect];
}

@end
