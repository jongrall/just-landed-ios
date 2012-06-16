//
//  AirlineResultTableViewCell.m
//  JustLanded
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "AirlineResultTableViewCell.h"

CGFloat const AirlineResultCellHeight = 44.0f;

@implementation AirlineResultTableViewCell

@synthesize airlineName;
@synthesize code;
@synthesize clearText;
@synthesize clearCell;

static UIFont *_nameFont;
static UIFont *_codeFont;
static UIFont *_clearFont;
static UIColor *_selectedCellBgColor;
static UIColor *_cellBgColor;
static UIColor *_textColor;
static UIColor *_clearTextColor;
static UIColor *_selectedTextColor;
static CGRect _textRect;



+ (void)initialize {
    if (self == [AirlineResultTableViewCell class]) {
        _nameFont = [JLStyles sansSerifLightOfSize:18.0f];
        _codeFont = [JLStyles sansSerifLightBoldOfSize:18.0f];
        _clearFont = [JLStyles sansSerifLightBoldOfSize:18.0f];
        _selectedCellBgColor = [UIColor colorWithRed:107.0f/255.0f green:157.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
        _cellBgColor = [UIColor whiteColor];
        _textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0 blue:51.0f/255.0f alpha:1.0f];
        _selectedTextColor = [UIColor whiteColor];
        _clearTextColor = [UIColor colorWithRed:107.0f/255.0f green:157.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
        _textRect = CGRectMake(14.0f, 14.0f, 292.0f, 22.0f);
    }
}


- (void)setAirlineName:(NSString *)aName {
    if (aName != airlineName) {
        airlineName = [aName stringByAppendingString:@" "];
        [self setNeedsDisplay];
    }
}


- (void)setCode:(NSString *)aCode {
    if (aCode != code) {
        code = [NSString stringWithFormat:@"(%@)", aCode];
        [self setNeedsDisplay];
    }
}

- (void)setClearText:(NSString *)text {
    if (text != clearText) {
        clearText = [text copy];
        [self setNeedsDisplay];
    }
}

- (void)setClearCell:(BOOL)flag {
    if (flag != clearCell) {
        clearCell = flag;
        [self setNeedsDisplay];
    }
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)isHighlighted {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the bg
    if (isHighlighted) {
        [_selectedCellBgColor set];
    }
    else {
        [_cellBgColor set];
    }
    
    CGContextFillRect(context, rect);
    
    if (isHighlighted) {
        [_selectedTextColor set];
    }
    else {
        if (clearCell) {
            [_clearTextColor set];
        }
        else {
            [_textColor set];
        }
    }
    
    if (!clearCell) {
        // Draw the text
        CGSize nameSize = [airlineName drawInRect:_textRect 
                                         withFont:_nameFont 
                                    lineBreakMode:UILineBreakModeMiddleTruncation 
                                        alignment:UITextAlignmentLeft];
        [code drawInRect:CGRectMake(_textRect.origin.x + nameSize.width, _textRect.origin.y, _textRect.size.width - nameSize.width, _textRect.size.height) 
                    withFont:_codeFont
               lineBreakMode:UILineBreakModeTailTruncation
                   alignment:UITextAlignmentLeft];
    }
    else {
        [clearText drawInRect:_textRect 
                     withFont:_clearFont 
                lineBreakMode:UILineBreakModeTailTruncation 
                    alignment:UITextAlignmentCenter];
    }
}

@end
