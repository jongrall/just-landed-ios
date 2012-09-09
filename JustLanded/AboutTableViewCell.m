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
CGRect const titleRect_ = {{75.0f, (AboutTableViewCellHeight / 2.0f) - 7.0f}, {AboutTableViewCellWidth - 84.0f, 20.0f}};
CGSize const highlightedShadowOffset_ = {0.0f, 0.0f};
CGPoint const iconCenter_ = {46.0f, 30.0f};

@implementation AboutTableViewCell

@synthesize title = title_;
@synthesize icon = icon_;
@synthesize downIcon = downIcon_;
@synthesize cellType = cellType_;
@synthesize hasDisclosureArrow = hasDisclosureArrow_;

static UIFont *sTitleFont_;
static UIColor *sTitleColor_;
static UIColor *sHighlightedTitleColor_;
static UIColor *sHighlightedShadowColor_;
static UIImage *sDisclosureArrow_;
static UIImage *sHighlightedDisclosureArrow_;
static UIImage *sDivider_;
static CGRect sDividerRect_;

+ (void)initialize {
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        if (self == [AboutTableViewCell class]) {
            sTitleFont_ = [JLStyles sansSerifLightOfSize:18.0f];
            sTitleColor_ = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f];
            sHighlightedTitleColor_ = [UIColor whiteColor];
            sHighlightedShadowColor_ = [UIColor whiteColor];
            sDisclosureArrow_ = [UIImage imageNamed:@"disclosure_arrow_up"];
            sHighlightedDisclosureArrow_ = [UIImage imageNamed:@"disclosure_arrow_down"];
            sDivider_ = [UIImage imageNamed:@"about_divider"];
            sDividerRect_ = CGRectMake((AboutTableViewCellWidth - sDivider_.size.width) / 2.0f,
                                      AboutTableViewCellHeight - sDivider_.size.height,
                                      sDivider_.size.width,
                                      sDivider_.size.height);
        }
    });
}


- (void)setTitle:(NSString *)aTitle {
    if (title_ != aTitle) {
        title_ = [aTitle copy];
        [self setNeedsDisplay];
    }
}


- (void)setIcon:(UIImage *)anIcon {
    if (icon_ != anIcon) {
        icon_ = anIcon;
        [self setNeedsDisplay];
    }
}


- (void)setDownIcon:(UIImage *)anIcon {
    if (downIcon_ != anIcon) {
        downIcon_ = anIcon;
        [self setNeedsDisplay];
    }
}


- (void)setCellType:(AboutCellType)aType {
    if (cellType_ != aType) {
        cellType_ = aType;
        [self setNeedsDisplay];
    }
}


- (void)setHasDisclosureArrow:(BOOL)flag {
    if (hasDisclosureArrow_ != flag) {
        hasDisclosureArrow_ = flag;
        [self setNeedsDisplay];
    }
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)isHighlighted {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Save the graphics state before we draw shadowed elements
    CGContextSaveGState(context);
    
    // Since we have transparency, need to hide/show correct cell backgrounds
    if (isHighlighted) {
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = NO;
    
        // Icons have highlight shadow built in
        [self.downIcon drawAtPoint:CGPointMake(roundf(iconCenter_.x - self.downIcon.size.width/2.0f), roundf(iconCenter_.y - self.downIcon.size.height/2.0f))
                    blendMode:kCGBlendModeNormal
                        alpha:0.87f];
        
        CGContextSetShadowWithColor(context, highlightedShadowOffset_, 4.0f, [sHighlightedShadowColor_ CGColor]);
    }
    else {
        self.backgroundView.hidden = NO;
        self.selectedBackgroundView.hidden = YES;
        
        // Icons have highlight shadow built in
        [self.icon drawAtPoint:CGPointMake(roundf(iconCenter_.x - self.icon.size.width/2.0f), roundf(iconCenter_.y - self.icon.size.height/2.0f))
                    blendMode:kCGBlendModeNormal
                        alpha:0.8f];
    }
    
    // Draw the text
    [sTitleColor_ set];
    
    [self.title drawInRect:titleRect_
                  withFont:sTitleFont_
             lineBreakMode:UILineBreakModeTailTruncation
                 alignment:UITextAlignmentLeft];

    // Stop drawing shadows
    CGContextRestoreGState(context);
    
    // Draw the disclosure arrow if needed
    if (self.hasDisclosureArrow) {
        UIImage *disclosureArrowToDraw = (isHighlighted) ? sHighlightedDisclosureArrow_ : sDisclosureArrow_;
        [disclosureArrowToDraw drawInRect:CGRectMake(contentView.frame.size.width - 47.0f,
                                                     (AboutTableViewCellHeight - disclosureArrowToDraw.size.height) / 2.0f,
                                                     disclosureArrowToDraw.size.width,
                                                     disclosureArrowToDraw.size.height)];
    }
    
    // Draw the divider below if necessary
    if (self.cellType != BOTTOM) {
        [sDivider_ drawInRect:sDividerRect_];
    }
}

@end
