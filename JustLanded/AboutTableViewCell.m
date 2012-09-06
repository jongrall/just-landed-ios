//
//  AboutTableViewCell.m
//  Just Landed
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
@synthesize downIcon;
@synthesize cellType;
@synthesize hasDisclosureArrow;

static UIFont *_titleFont;
static UIColor *_titleColor;
static UIColor *_highlightedTitleColor;
static UIColor *_shadowColor;
static UIColor *_highlightedShadowColor;
static UIImage *_disclosureArrow;
static UIImage *_highlightedDisclosureArrow;
static UIImage *_divider;
static CGRect _titleRect;
static CGRect _dividerRect;
static CGSize _shadowOffset;
static CGSize _highlightedShadowOffset;
static CGPoint _iconCenter;

+ (void)initialize {
    if (self == [AboutTableViewCell class]) {
        _titleFont = [JLStyles sansSerifLightOfSize:18.0f];
        _titleColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f];
        _highlightedTitleColor = [UIColor whiteColor];
        _shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.3f];
        _highlightedShadowColor = [UIColor whiteColor];
        _disclosureArrow = [UIImage imageNamed:@"disclosure_arrow_up"];
        _highlightedDisclosureArrow = [UIImage imageNamed:@"disclosure_arrow_down"];
        _divider = [UIImage imageNamed:@"about_divider"];
        _titleRect = CGRectMake(75.0f, (AboutTableViewCellHeight / 2.0f) - 7.0f, AboutTableViewCellWidth - 84.0f, 20.0f);
        _dividerRect = CGRectMake((AboutTableViewCellWidth - _divider.size.width) / 2.0f,
                                  AboutTableViewCellHeight - _divider.size.height,
                                  _divider.size.width,
                                  _divider.size.height);
        _shadowOffset = CGSizeMake(0.0f, 0.5f);
        _highlightedShadowOffset = CGSizeZero;
        _iconCenter = CGPointMake(46.0f, 30.0f);
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


- (void)setDownIcon:(UIImage *)anIcon {
    if (downIcon != anIcon) {
        downIcon = anIcon;
        [self setNeedsDisplay];
    }
}


- (void)setCellType:(AboutCellType)aType {
    if (cellType != aType) {
        cellType = aType;
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
    
    // Since we have transparency, need to hide/show correct cell backgrounds
    if (isHighlighted) {
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = NO;
    
        // Icons have highlight shadow built in
        [downIcon drawAtPoint:CGPointMake(roundf(_iconCenter.x - downIcon.size.width/2.0f), roundf(_iconCenter.y - downIcon.size.height/2.0f))
                    blendMode:kCGBlendModeNormal
                        alpha:0.87f];
        
        // Save the graphics state before we draw shadowed elements
        CGContextSaveGState(context);
        
        CGContextSetShadowWithColor(context, _highlightedShadowOffset, 4.0f, [_highlightedShadowColor CGColor]);
    }
    else {
        self.backgroundView.hidden = NO;
        self.selectedBackgroundView.hidden = YES;
        
        // Icons have highlight shadow built in
        [icon drawAtPoint:CGPointMake(roundf(_iconCenter.x - icon.size.width/2.0f), roundf(_iconCenter.y - icon.size.height/2.0f))
                    blendMode:kCGBlendModeNormal
                        alpha:0.8f];
        
        // Save the graphics state before we draw shadowed elements
        CGContextSaveGState(context);
        
        CGContextSetShadowWithColor(context, _shadowOffset, 0.0f, [_shadowColor CGColor]);
    }
    
    // Draw the text
    [_titleColor set];
    
    [title drawInRect:_titleRect
             withFont:_titleFont
        lineBreakMode:UILineBreakModeTailTruncation
            alignment:UITextAlignmentLeft];

    // Stop drawing shadows
    CGContextRestoreGState(context);
    
    // Draw the disclosure arrow if needed
    if (hasDisclosureArrow) {
        UIImage *disclosureArrowToDraw = (isHighlighted) ? _highlightedDisclosureArrow : _disclosureArrow;
        [disclosureArrowToDraw drawInRect:CGRectMake(contentView.frame.size.width - 47.0f,
                                                     (AboutTableViewCellHeight - disclosureArrowToDraw.size.height) / 2.0f,
                                                     disclosureArrowToDraw.size.width,
                                                     disclosureArrowToDraw.size.height)];
    }
    
    // Draw the divider below if necessary
    if (cellType != BOTTOM) {
        [_divider drawInRect:_dividerRect];
    }
}

@end
