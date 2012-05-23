//
//  JLMultipartOverUnderLabel.m
//  JustLanded
//
//  Created by Jon Grall on 4/21/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMultipartOverUnderLabel.h"

@implementation JLMultipartOverUnderLabel

@synthesize labelSeparation;


- (void)setParts:(NSArray *)parts {
    NSAssert([parts count] % 2 == 0, @"Odd number of label parts!");
    [super setParts:parts];
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    // Calculate the offsets of each part
    CGFloat midpoint = rect.size.width / 2.0f;
    CGFloat totalWidth = 0.0f;
    
    for (int i = 0; i < [self.parts count]; i=i+2) {
        NSString *nextPart = [self.parts objectAtIndex:i];
        LabelStyle *nextStyle;
        
        if (self.styles) {
            nextStyle = ([self.styles count] > i) ? [self.styles objectAtIndex:i] : [self.styles lastObject];
        }
        else {
            break; // Unrecoverable, we need at least one text style
        }
        
        CGSize nextPartSize = [nextPart sizeWithFont:[[nextStyle textStyle] font]];
        totalWidth += nextPartSize.width;
    }
    
    NSUInteger numSeparators = ([self.parts count]/2 - 1) > 0 ? [self.parts count]/2 - 1 : 0;
    totalWidth = totalWidth + numSeparators * labelSeparation;
    CGPoint startPoint = CGPointMake(midpoint - (totalWidth / 2.0f), 0.0f);
 
    for (int i = 0; i < [self.parts count]; i=i+2) {
        NSString *nextUpperPart = [self.parts objectAtIndex:i];
        NSString *nextUnderPart = [self.parts objectAtIndex:i+1];
        
        // Get the next offset, guard against programmer error
        CGSize nextUpperOffset = CGSizeZero;
        CGSize nextLowerOffset = CGSizeZero;
        if (self.offsets) {
            nextUpperOffset = ([self.offsets count] > i) ? [[self.offsets objectAtIndex:i] CGSizeValue] : [[self.offsets lastObject] CGSizeValue];
            nextLowerOffset = ([self.offsets count] > i+1) ? [[self.offsets objectAtIndex:i+1] CGSizeValue] : [[self.offsets lastObject] CGSizeValue];
        }
        
        LabelStyle *nextUpperStyle;
        LabelStyle *nextLowerStyle;
        
        // Get the next style, guard against programmer error
        if (self.styles) {
            nextUpperStyle = ([self.styles count] > i) ? [self.styles objectAtIndex:i] : [self.styles lastObject];
            nextLowerStyle = ([self.styles count] > i+1) ? [self.styles objectAtIndex:i+1] : [self.styles lastObject];
        }
        else {
            break; // Unrecoverable, we need at least one text style
        }
            
        TextStyle *upperTextStyle = [nextUpperStyle textStyle];
        TextStyle *lowerTextStyle = [nextLowerStyle textStyle];
        
        // Draw the upper part
        CGContextSaveGState(context);
        
        // Shadow
        if ([upperTextStyle shadowColor]) {
            CGContextSetShadowWithColor(context, [upperTextStyle shadowOffset], [upperTextStyle shadowBlur], [[upperTextStyle shadowColor] CGColor]);
        }
        
        [[upperTextStyle color] set];
        CGSize snippetSize = [nextUpperPart drawAtPoint:CGPointMake(startPoint.x + nextUpperOffset.width,
                                                                    startPoint.y + nextUpperOffset.height) 
                                               withFont:[upperTextStyle font]];
        
        CGContextRestoreGState(context);
        
        // Draw the under part
        CGContextSaveGState(context);
        CGSize underSize = [nextUnderPart sizeWithFont:[lowerTextStyle font]];
        CGPoint underStartPoint = CGPointMake(startPoint.x + (snippetSize.width / 2.0f) - underSize.width/2.0f + nextLowerOffset.width,
                                              nextLowerOffset.height);
        
        // Shadow
        if ([lowerTextStyle shadowColor]) {
            CGContextSetShadowWithColor(context, [lowerTextStyle shadowOffset], [lowerTextStyle shadowBlur], [[lowerTextStyle shadowColor] CGColor]);
        }
        
        [[lowerTextStyle color] set];
        [nextUnderPart drawAtPoint:underStartPoint withFont:[lowerTextStyle font]];
        CGContextRestoreGState(context);
        
        startPoint = CGPointMake(startPoint.x + snippetSize.width + labelSeparation,
                                 startPoint.y);
    }
}

@end
