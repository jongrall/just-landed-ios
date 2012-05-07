//
//  FlightResultTableViewCell.m
//  JustLanded
//
//  Created by Jon Grall on 2/20/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "FlightResultTableViewCell.h"

CGFloat const FlightResultTableViewCellWidth = 288.0f;
CGFloat const FlightResultTableViewCellHeight = 60.0f;

@interface FlightResultTableViewCell () 

@property (strong, nonatomic) UIImage *_flightIcon;
@property (strong, nonatomic) UIImage *_arrowIcon;

@end



@implementation FlightResultTableViewCell

@synthesize toAirport;
@synthesize fromAirport;
@synthesize status;
@synthesize statusColor;
@synthesize statusShadowColor;
@synthesize landingTime;
@synthesize cellType;
@synthesize inFlight;
@synthesize _flightIcon;
@synthesize _arrowIcon;

static UIFont *_toFromAirportFont;
static UIFont *_statusFont;
static UIFont *_landingTimeFont;
static UIColor *_textColor;
static UIImage *_topBg;
static UIImage *_topBgSelected;
static UIImage *_middleBg;
static UIImage *_middleBgSelected;
static UIImage *_bottomBg;
static UIImage *_bottomBgSelected;
static CGRect _toFromAirportRect;
static CGRect _landingTimeRect;
static CGRect _statusRect;
static CGSize _shadowOffset;
static CGPoint _flightIconOrigin;

+ (void)initialize {
    if (self == [FlightResultTableViewCell class]) {
        _toFromAirportFont = [JLStyles sansSerifLightBoldOfSize:13.5f];
        _statusFont = [JLStyles regularScriptOfSize:19.0f];
        _landingTimeFont = [JLStyles sansSerifLightOfSize:13.5f];
        _textColor = [UIColor whiteColor];
        _topBg = [[UIImage imageNamed:@"table_cell_top"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _topBgSelected = [[UIImage imageNamed:@"table_cell_top_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _middleBg = [[UIImage imageNamed:@"table_cell_middle"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _middleBgSelected = [[UIImage imageNamed:@"table_cell_middle_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _bottomBg = [[UIImage imageNamed:@"table_cell_bottom"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _bottomBgSelected = [[UIImage imageNamed:@"table_cell_bottom_selected"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        _toFromAirportRect = CGRectMake(13.5f, 14.0f, FlightResultTableViewCellWidth - 27.0f, 30.0f);
        _landingTimeRect = CGRectMake(38.0f, 35.0f, FlightResultTableViewCellWidth - 51.5f - 60.0f, 30.0f);
        _statusRect = CGRectMake(_landingTimeRect.origin.x + _landingTimeRect.size.width, 31.0f, 60.0f, 30.0f);
        _shadowOffset = CGSizeMake(0.0f, 1.0f);
        _flightIconOrigin = CGPointMake(13.5f, 34.0f);
    }
}


- (void)setToAirport:(NSString *)anAirport {
    if (toAirport != anAirport) {
        toAirport = [anAirport uppercaseString];
        [self setNeedsDisplay];
    }
}


- (void)setFromAirport:(NSString *)anAirport {
    if (fromAirport != anAirport) {
        fromAirport = [anAirport uppercaseString];
        [self setNeedsDisplay];
    }
}


- (void)setStatus:(NSString *)aStatus {
    if (status != aStatus) {
        status = [aStatus lowercaseString];
        [self setNeedsDisplay];
    }
}


- (void)setStatusColor:(UIColor *)aStatusColor {
    if (statusColor != aStatusColor) {
        statusColor = aStatusColor;
        [self setNeedsDisplay];
    }
}


- (void)setStatusShadowColor:(UIColor *)aColor {
    if (statusShadowColor != aColor) {
        statusShadowColor = aColor;
        self._flightIcon = [UIImage imageNamed:@"plane_landing" 
                                     withColor:_textColor 
                                   shadowColor:statusShadowColor 
                                  shadowOffset:CGSizeMake(0.0f, -1.0f) 
                                    shadowBlur:0.0f];
        self._arrowIcon = [UIImage imageNamed:@"table_arrow" 
                                    withColor:_textColor 
                                  shadowColor:statusShadowColor 
                                 shadowOffset:CGSizeMake(0.0f, -1.0f)
                                   shadowBlur:0.0f];
        
        [self setNeedsDisplay];
    }
}

- (void)setLandingTime:(NSString *)aLandingTime {
    if (landingTime != aLandingTime) {
        landingTime = [aLandingTime copy];
        [self setNeedsDisplay];
    }
}


- (void)setCellType:(FlightResultCellType)aType {
    if (cellType != aType) {
        cellType = aType;
        [self setNeedsDisplay];
    }
}


- (void)setInFlight:(BOOL)flag {
    if (inFlight != flag) {
        inFlight = flag;
        [self setNeedsDisplay];
    }
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)isHighlighted {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (cellType == TOP) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                           cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [path addClip];
    }
    else if (cellType == BOTTOM) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [path addClip];
    }
    
    //Draw the background status color
	[statusColor set]; 
    
    CGContextFillRect(context, rect);
    
    // Draw the text
    [_textColor set];
    
    CGContextSaveGState(context);
    if (isHighlighted) {
        CGContextTranslateCTM(context, 0.0f, 1.0f);
    }
    
    // Save the graphics state before we draw shadowed elements
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, -1.0f), 0.0f, [statusShadowColor CGColor]);
    
    // Draw the to - from airport text
    CGSize fromAirportSize = [fromAirport drawAtPoint:_toFromAirportRect.origin
                                             forWidth:_toFromAirportRect.size.width / 2.0f 
                                             withFont:_toFromAirportFont 
                                        lineBreakMode:UILineBreakModeTailTruncation];
    
    [toAirport drawAtPoint:CGPointMake(_toFromAirportRect.origin.x + fromAirportSize.width + _arrowIcon.size.width + 8.0f,
                                       _toFromAirportRect.origin.y) 
                  forWidth:_toFromAirportRect.size.width / 2.0f
                  withFont:_toFromAirportFont
             lineBreakMode:UILineBreakModeTailTruncation];
    
    
    // Stop drawing shadows
    CGContextRestoreGState(context);
    
    // Draw the plane icon
    [_flightIcon drawInRect:CGRectMake(_flightIconOrigin.x, 
                                       _flightIconOrigin.y,
                                       _flightIcon.size.width, 
                                       _flightIcon.size.height)];
    
    // Draw the arrow between the locations
    [_arrowIcon drawInRect:CGRectMake(_toFromAirportRect.origin.x + fromAirportSize.width + 3.0f,
                                      _toFromAirportRect.origin.y - 1.0f,
                                      _arrowIcon.size.width,
                                      _arrowIcon.size.height)];
    
    // Draw the landing time text
    [landingTime drawInRect:_landingTimeRect 
                   withFont:_landingTimeFont 
              lineBreakMode:UILineBreakModeTailTruncation 
                  alignment:UITextAlignmentLeft];
    
    // Draw the status text
    [status drawInRect:_statusRect
              withFont:_statusFont
         lineBreakMode:UILineBreakModeTailTruncation 
             alignment:UITextAlignmentRight];
    
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
