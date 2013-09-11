//
//  FlightResultTableViewCell.m
//  Just Landed
//
//  Created by Jon Grall on 2/20/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "FlightResultTableViewCell.h"

CGFloat const FlightResultTableViewCellWidth = 288.0f;
CGFloat const FlightResultTableViewCellHeight = 60.0f;
CGRect const toFromAirportRect_ = {{13.5f, 14.0f}, {FlightResultTableViewCellWidth - 27.0f, 30.0f}};
CGRect const landingTimeRect_ = {{38.0f, 35.0f}, {FlightResultTableViewCellWidth - 51.5f - 60.0f, 20.0f}};
CGRect const statusRect_ = {{38.0f + FlightResultTableViewCellWidth - 51.5f - 60.0f, 31.0f}, {60.0f, 20.0f}};
CGSize const shadowOffset_ = {0.0f, -1.0f};
CGPoint const flightIconOrigin_ = {13.5f, 34.0f};

@interface FlightResultTableViewCell ()

@property (strong, nonatomic) UIImage *flightIcon_;
@property (strong, nonatomic) UIImage *arrowIcon_;

@end



@implementation FlightResultTableViewCell

@synthesize toAirport = toAirport_;
@synthesize fromAirport = fromAirport_;
@synthesize status = status_;
@synthesize statusColor = statusColor_;
@synthesize statusShadowColor = statusShadowColor_;
@synthesize landingTime = landingTime_;
@synthesize cellType = cellType_;
@synthesize inFlight = inFlight_;
@synthesize flightIcon_;
@synthesize arrowIcon_;

static UIFont *sToFromAirportFont_;
static UIFont *sStatusFont_;
static UIFont *sLandingTimeFont_;
static UIColor *sTextColor_;
static UIImage *sTopBackground_;
static UIImage *sTopBackgroundSelected_;
static UIImage *sMiddleBackground_;
static UIImage *sMiddleBackgroundSelected_;
static UIImage *sBottomBackground_;
static UIImage *sBottomBackgroundSelected_;

+ (void)initialize {
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        if (self == [FlightResultTableViewCell class]) {
            sToFromAirportFont_ = [JLStyles sansSerifLightBoldOfSize:13.5f];
            sStatusFont_ = [JLStyles regularScriptOfSize:19.0f];
            sLandingTimeFont_ = [JLStyles sansSerifLightOfSize:13.5f];
            sTextColor_ = [UIColor whiteColor];
            sTopBackground_ = [[UIImage imageNamed:@"table_cell_top"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
            sTopBackgroundSelected_ = [[UIImage imageNamed:@"table_cell_top_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
            sMiddleBackground_ = [[UIImage imageNamed:@"table_cell_middle"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
            sMiddleBackgroundSelected_ = [[UIImage imageNamed:@"table_cell_middle_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
            sBottomBackground_ = [[UIImage imageNamed:@"table_cell_bottom"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
            sBottomBackgroundSelected_ = [[UIImage imageNamed:@"table_cell_bottom_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        }
    });
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [UIColor clearColor];
    };

    return self;
}

- (void)setToAirport:(NSString *)anAirport {
    if (toAirport_ != anAirport) {
        toAirport_ = [anAirport uppercaseString];
        [self setNeedsDisplay];
    }
}


- (void)setFromAirport:(NSString *)anAirport {
    if (fromAirport_ != anAirport) {
        fromAirport_ = [anAirport uppercaseString];
        [self setNeedsDisplay];
    }
}


- (void)setStatus:(NSString *)aStatus {
    if (status_ != aStatus) {
        status_ = [aStatus lowercaseString];
        [self setNeedsDisplay];
    }
}


- (void)setStatusColor:(UIColor *)aStatusColor {
    if (statusColor_ != aStatusColor) {
        statusColor_ = aStatusColor;
        [self setNeedsDisplay];
    }
}


- (void)setStatusShadowColor:(UIColor *)aColor {
    if (statusShadowColor_ != aColor) {
        statusShadowColor_ = aColor;
        self.flightIcon_ = [UIImage imageNamed:@"plane_landing" 
                                     withColor:sTextColor_ 
                                   shadowColor:statusShadowColor_
                                  shadowOffset:shadowOffset_
                                    shadowBlur:0.0f];
        self.arrowIcon_ = [UIImage imageNamed:@"table_arrow" 
                                    withColor:sTextColor_ 
                                  shadowColor:statusShadowColor_
                                 shadowOffset:shadowOffset_
                                   shadowBlur:0.0f];
        
        [self setNeedsDisplay];
    }
}

- (void)setLandingTime:(NSString *)aLandingTime {
    if (landingTime_ != aLandingTime) {
        landingTime_ = [aLandingTime copy];
        [self setNeedsDisplay];
    }
}


- (void)setCellType:(FlightResultCellType)aType {
    if (cellType_ != aType) {
        cellType_ = aType;
        
        if (cellType_ == BOTTOM) {
            CGRect bounds = CGRectMake(0.0f, 0.0f, FlightResultTableViewCellWidth, FlightResultTableViewCellHeight + 2.0f);
            [self setBounds:bounds];
            [self.contentView setBounds:bounds];
        }
        else {
            CGRect bounds = CGRectMake(0.0f, 0.0f, FlightResultTableViewCellWidth, FlightResultTableViewCellHeight);
            [self setBounds:bounds];
            [self.contentView setBounds:bounds];
        }
        
        [self setNeedsDisplay];
    }
}


- (void)setInFlight:(BOOL)flag {
    if (inFlight_ != flag) {
        inFlight_ = flag;
        [self setNeedsDisplay];
    }
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)isHighlighted {
    if (!isHighlighted) {
        self.backgroundView.hidden = NO;
        self.selectedBackgroundView.hidden = YES;
    }
    else {
        self.backgroundView.hidden = YES;
        self.selectedBackgroundView.hidden = NO;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (cellType_ == BOTTOM) {
        CGContextSaveGState(context);
    }
        
    CGRect backgroundBounds = CGRectMake(0.0f, 0.0f, FlightResultTableViewCellWidth, FlightResultTableViewCellHeight);
    
    if (cellType_ == TOP) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backgroundBounds
                                                byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                           cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [path addClip];
    }
    else if (cellType_ == BOTTOM) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backgroundBounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [path addClip];
    }
    
    //Draw the background status color
	[statusColor_ set];
    
    CGContextFillRect(context, backgroundBounds);
    
    if (cellType_ == BOTTOM) {
        CGContextRestoreGState(context);
    }
    
    // Draw the text
    [sTextColor_ set];
    
    CGContextSaveGState(context);
    if (isHighlighted) {
        CGContextTranslateCTM(context, 0.0f, 1.0f);
    }
    
    // Save the graphics state before we draw shadowed elements
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset_, 0.0f, [statusShadowColor_ CGColor]);
    
    // Draw the to - from airport text
    CGSize fromAirportSize = [fromAirport_ drawAtPoint:toFromAirportRect_.origin
                                              forWidth:toFromAirportRect_.size.width / 2.0f
                                              withFont:sToFromAirportFont_
                                         lineBreakMode:NSLineBreakByTruncatingTail];
    
    [toAirport_ drawAtPoint:CGPointMake(toFromAirportRect_.origin.x + fromAirportSize.width + arrowIcon_.size.width + 8.0f,
                                        toFromAirportRect_.origin.y)
                   forWidth:toFromAirportRect_.size.width / 2.0f
                   withFont:sToFromAirportFont_
              lineBreakMode:NSLineBreakByTruncatingTail];
    
    
    // Stop drawing shadows
    CGContextRestoreGState(context);
    
    // Draw the plane icon
    [flightIcon_ drawInRect:CGRectMake(flightIconOrigin_.x,
                                       flightIconOrigin_.y,
                                       flightIcon_.size.width,
                                       flightIcon_.size.height)];
    
    // Draw the arrow between the locations
    [arrowIcon_ drawInRect:CGRectMake(toFromAirportRect_.origin.x + fromAirportSize.width + 3.0f,
                                      toFromAirportRect_.origin.y - 1.0f,
                                      arrowIcon_.size.width,
                                      arrowIcon_.size.height)];
    
    // Draw the landing time text
    [landingTime_ drawInRect:landingTimeRect_
                    withFont:sLandingTimeFont_
               lineBreakMode:NSLineBreakByClipping
                   alignment:NSTextAlignmentLeft];
    
    // Draw the status text
    [status_ drawInRect:statusRect_
               withFont:sStatusFont_
          lineBreakMode:NSLineBreakByTruncatingTail
              alignment:NSTextAlignmentRight];
    
    CGContextRestoreGState(context);
    
    // Draw the border on top
    if (!isHighlighted) {
        switch (cellType_) {
            case TOP: {
                [sTopBackground_ drawInRect:rect];
                break;
            }
            case MIDDLE: {
                [sMiddleBackground_ drawInRect:rect];
                break;
            }
            case BOTTOM: {
                [sBottomBackground_ drawInRect:rect];
                break;
            }
            default:
                break;
        }
    }
    else {
        switch (cellType_) {
            case TOP: {
                [sTopBackgroundSelected_ drawInRect:rect];
                break;
            }
            case MIDDLE: {
                [sMiddleBackgroundSelected_ drawInRect:rect];
                break;
            }
            case BOTTOM: {
                [sBottomBackgroundSelected_ drawInRect:rect];
                break;
            }
            default:
                break;
        }
    }
}

@end
