//
//  AboutTableViewCell.m
//  JustLanded
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "AboutTableViewCell.h"

CGFloat const AboutTableViewCellWidth = 306.0f;
CGFloat const AboutTableViewCellHeight = 60.0f;

@implementation AboutTableViewCell

@synthesize title;
@synthesize icon;
@synthesize cellType;
@synthesize hasDisclosureArrow;

static UIFont *_titleFont;
static UIColor *_titleColor;
static UIColor *_bgColor;
static UIColor *_shadowColor;
static UIImage *_topBg;
static UIImage *_topBgSelected;
static UIImage *_middleBg;
static UIImage *_middleBgSelected;
static UIImage *_bottomBg;
static UIImage *_bottomBgSelected;
static UIImage *_disclosureArrow;
static CGRect _titleRect;
static CGSize _shadowOffset;
static CGPoint _iconCenter;

+ (void)initialize {
    if (self == [AboutTableViewCell class]) {
        _titleFont = [JLStyles sansSerifLightBoldOfSize:18.0f];
        _titleColor = [UIColor whiteColor];
        _bgColor = [UIColor colorWithRed:12.0f/255.0f green:114.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
        _shadowColor = [UIColor colorWithRed:16.0f/255.0f green:82.0f/255.0f blue:113.0f/255.0f alpha:1.0f];
        _topBg = [[UIImage imageNamed:@"table_cell_top"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _topBgSelected = [[UIImage imageNamed:@"table_cell_top_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _middleBg = [[UIImage imageNamed:@"table_cell_middle"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _middleBgSelected = [[UIImage imageNamed:@"table_cell_middle_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _bottomBg = [[UIImage imageNamed:@"table_cell_bottom"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _bottomBgSelected = [[UIImage imageNamed:@"table_cell_bottom_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _disclosureArrow = [UIImage imageNamed:@"disclosure_arrow"];
        _titleRect = CGRectMake(64.0f, (AboutTableViewCellHeight / 2.0f) - 7.0f, AboutTableViewCellWidth - 84.0f, 20.0f);
        _shadowOffset = CGSizeMake(0.0f, -1.0f);
        _iconCenter = CGPointMake(30.0f, 30.0f);
    }
}


- (void)setTitle:(NSString *)aTitle {
    if (title != aTitle) {
        title = [aTitle copy];
        [self setNeedsDisplay];
    }
}


- (void)setIcon:(UIImage *)anIcon {
    if (icon != anIcon) {
        icon = anIcon;
        [self setNeedsDisplay];
    }
}


- (void)setCellType:(AboutCellType)aType {
    if (cellType != aType) {
        cellType = aType;
        
        if (cellType == BOTTOM) {
            CGRect bounds = CGRectMake(0.0f, 0.0f, AboutTableViewCellWidth, AboutTableViewCellHeight + 2.0f);
            [self setBounds:bounds];
            [self.contentView setBounds:bounds];
        }
        else {
            CGRect bounds = CGRectMake(0.0f, 0.0f, AboutTableViewCellWidth, AboutTableViewCellHeight - 1.0f);
            [self setBounds:bounds];
            [self.contentView setBounds:bounds];
        }
        
        [self setNeedsDisplay];
    }
}


- (void)setHasDisclosureArrow:(BOOL)flag {
    if (hasDisclosureArrow != flag) {
        hasDisclosureArrow = flag;
        [self setNeedsDisplay];
    }
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)isHighlighted {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!isHighlighted) {
        self.backgroundView.hidden = NO;
        self.selectedBackgroundView.hidden = YES;
    }
    else {
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = NO;
    }
    
    if (cellType == BOTTOM) {
        CGContextSaveGState(context);
    }
    
    if (cellType == TOP) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [path addClip];
    }
    else if (cellType == BOTTOM) {
        CGRect bgBounds = CGRectMake(0.0f, 0.0f, rect.size.width, AboutTableViewCellHeight);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bgBounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [path addClip];
    }
    
    //Draw the background color
	[_bgColor set]; 
    
    CGContextFillRect(context, rect);
    
    if (cellType == BOTTOM) {
        CGContextRestoreGState(context);
    }
    
    // Draw the text
    [_titleColor set];
    
    CGContextSaveGState(context);
    if (isHighlighted) {
        CGContextTranslateCTM(context, 0.0f, 1.0f);
    }
    
    // Save the graphics state before we draw shadowed elements
    CGContextSetShadowWithColor(context, _shadowOffset, 0.0f, [_shadowColor CGColor]);
    
    [icon drawAtPoint:CGPointMake(roundf(_iconCenter.x - icon.size.width/2.0f), roundf(_iconCenter.y - icon.size.height/2.0f))];
    
    [title drawInRect:_titleRect 
             withFont:_titleFont 
        lineBreakMode:UILineBreakModeTailTruncation 
            alignment:UITextAlignmentLeft];
    
    
    // Draw the disclosure arrow if needed
    if (hasDisclosureArrow) {
        [_disclosureArrow drawInRect:CGRectMake(contentView.frame.size.width - 25.0f,
                                                (AboutTableViewCellHeight - _disclosureArrow.size.height) / 2.0f,
                                                _disclosureArrow.size.width,
                                                _disclosureArrow.size.height)];
    }
    
    // Stop drawing shadows
    CGContextRestoreGState(context);
    
    // Draw the border on top
    if (isHighlighted) {
        switch (cellType) {
            case TOP:
                [_topBgSelected drawInRect:rect];
                break;
            case MIDDLE:
                [_middleBgSelected drawInRect:rect];
                break;
            default:
                [_bottomBgSelected drawInRect:rect];
                break;
        }
    }
    else {
        switch (cellType) {
            case TOP:
                [_topBg drawInRect:rect];
                break;
            case MIDDLE:
                [_middleBg drawInRect:rect];
                break;
            default:
                [_bottomBg drawInRect:rect];
                break;
        }
    }
}

@end
