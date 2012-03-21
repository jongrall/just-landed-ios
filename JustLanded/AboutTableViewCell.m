//
//  AboutTableViewCell.m
//  JustLanded
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "AboutTableViewCell.h"

CGFloat const AboutTableViewCellWidth = 300.0f;
CGFloat const AboutTableViewCellHeight = 50.0f;

@implementation AboutTableViewCell

@synthesize title;

static UIFont *_titleFont;
static UIColor *_titleColor;
static UIColor *_bgColor;
static UIColor *_selectedBgColor;
static UIColor *_selectedTextColor;
static CGRect _bgFillRect;
static CGRect _titleRect;
static CGSize _shadowOffset;

+ (void)initialize {
    if (self == [AboutTableViewCell class]) {
        _titleFont = [UIFont systemFontOfSize:16.0f];
        _titleColor = [UIColor blackColor];
        _bgColor = [UIColor whiteColor];
        _selectedBgColor = [UIColor blueColor];
        _selectedTextColor = [UIColor whiteColor];
        _bgFillRect = CGRectMake(0.0f, 0.0f, AboutTableViewCellWidth, AboutTableViewCellHeight);
        _titleRect = CGRectMake(10.0f, (AboutTableViewCellHeight / 2.0f) - 10.0f, AboutTableViewCellWidth - 20.0f, 20.0f);
        _shadowOffset = CGSizeMake(0.0f, 1.0f);
    }
}


- (void)setTitle:(NSString *)aTitle {
    if (title != aTitle) {
        title = [aTitle copy];
        [self setNeedsDisplay];
    }
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)isHighlighted {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	//Draw the background
	if (isHighlighted) {
		[_selectedBgColor set];
	}
	else {
		[_bgColor set];
	}
    
    CGContextFillRect(context, _bgFillRect);
    
    if (isHighlighted) {
        [_selectedTextColor set];
    }
    else {
        [_titleColor set];
    }
    
    [title drawInRect:_titleRect 
             withFont:_titleFont
        lineBreakMode:UILineBreakModeMiddleTruncation 
            alignment:UITextAlignmentLeft];
}

@end
