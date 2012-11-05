//
//  JLMultipartOverUnderLabel.m
//  Just Landed
//
//  Created by Jon Grall on 4/21/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLMultipartOverUnderLabel.h"

@implementation JLMultipartOverUnderLabel

@synthesize labelSeparation = labelSeparation_;

- (void)setParts:(NSArray *)parts {
    NSAssert([parts count] % 2 == 0, @"Odd number of label parts!");
    [super setParts:parts];
}


- (void)drawRect:(CGRect)rect {
    NSArray *offsets_ = self.offsets;
    NSArray *parts_ = self.parts;
    NSArray *styles_ = self.styles;
    
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    // Calculate the offsets of each part
    CGFloat midpoint = rect.size.width / 2.0f;
    CGFloat totalWidth = 0.0f;
    
    for (NSUInteger i = 0; i < [parts_ count]; i = i + 2) {
        NSString *nextPart = parts_[i];
        LabelStyle *nextStyle;
        
        if (styles_) {
            nextStyle = ([styles_ count] > i) ? styles_[i] : [styles_ lastObject];
        }
        else {
            break; // Unrecoverable, we need at least one text style
        }
        
        CGSize nextPartSize = [nextPart sizeWithFont:nextStyle.textStyle.font];
        totalWidth += nextPartSize.width;
    }
    
    NSUInteger numSeparators = ([parts_ count]/2 - 1) > 0 ? [parts_ count]/2 - 1 : 0;
    totalWidth = totalWidth + numSeparators * labelSeparation_;
    CGPoint startPoint = CGPointMake(midpoint - (totalWidth / 2.0f), 0.0f);
 
    for (NSUInteger i = 0; i < [parts_ count]; i = i + 2) {
        NSString *nextUpperPart = parts_[i];
        NSString *nextUnderPart = parts_[i+1];
        
        // Get the next offset, guard against programmer error
        CGSize nextUpperOffset = CGSizeZero;
        CGSize nextLowerOffset = CGSizeZero;
        if (offsets_) {
            nextUpperOffset = ([offsets_ count] > i) ? [offsets_[i] CGSizeValue] : [[offsets_ lastObject] CGSizeValue];
            nextLowerOffset = ([offsets_ count] > i+1) ? [offsets_[i+1] CGSizeValue] : [[offsets_ lastObject] CGSizeValue];
        }
        
        LabelStyle *nextUpperStyle;
        LabelStyle *nextLowerStyle;
        
        // Get the next style, guard against programmer error
        if (styles_) {
            nextUpperStyle = ([styles_ count] > i) ? styles_[i] : [styles_ lastObject];
            nextLowerStyle = ([styles_ count] > i+1) ? styles_[i+1] : [styles_ lastObject];
        }
        else {
            break; // Unrecoverable, we need at least one text style
        }
            
        TextStyle *upperTextStyle = nextUpperStyle.textStyle;
        TextStyle *lowerTextStyle = nextLowerStyle.textStyle;
        
        // Draw the upper part
        CGContextSaveGState(context);
        
        // Shadow
        if (upperTextStyle.shadowColor) {
            CGContextSetShadowWithColor(context, upperTextStyle.shadowOffset, upperTextStyle.shadowBlur, [upperTextStyle.shadowColor CGColor]);
        }
        
        [upperTextStyle.color set];
        CGSize snippetSize = [nextUpperPart drawAtPoint:CGPointMake(startPoint.x + nextUpperOffset.width,
                                                                    startPoint.y + nextUpperOffset.height) 
                                               withFont:upperTextStyle.font];
        
        CGContextRestoreGState(context);
        
        // Draw the under part
        CGContextSaveGState(context);
        CGSize underSize = [nextUnderPart sizeWithFont:lowerTextStyle.font];
        CGPoint underStartPoint = CGPointMake(roundf(startPoint.x + (snippetSize.width / 2.0f) - underSize.width/2.0f + nextLowerOffset.width),
                                              nextLowerOffset.height);
        
        // Shadow
        if (lowerTextStyle.shadowColor) {
            CGContextSetShadowWithColor(context, lowerTextStyle.shadowOffset, lowerTextStyle.shadowBlur, [lowerTextStyle.shadowColor CGColor]);
        }
        
        [lowerTextStyle.color set];
        [nextUnderPart drawAtPoint:underStartPoint withFont:lowerTextStyle.font];
        CGContextRestoreGState(context);
        
        startPoint = CGPointMake(startPoint.x + snippetSize.width + labelSeparation_,
                                 startPoint.y);
    }
}

@end
