//
//  FlightResultTableViewCell.m
//  JustLanded
//
//  Created by Jon Grall on 2/20/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "FlightResultTableViewCell.h"

CGFloat const FlightResultTableViewCellWidth = 280.0f;
CGFloat const FlightResultTableViewCellHeight = 55.0f;

@interface FlightResultTableViewCell () 

@property (strong, nonatomic) NSString *_toFromAirport;

@end



@implementation FlightResultTableViewCell

@synthesize toAirport;
@synthesize fromAirport;
@synthesize status;
@synthesize statusColor;
@synthesize landingTime;
@synthesize _toFromAirport;

static UIFont *_toFromAirportFont;
static UIFont *_statusFont;
static UIFont *_landingTimeFont;
static UIColor *_toFromAirportColor;
static UIColor *_landingTimeColor;
static UIColor *_bgColor;
static UIColor *_selectedBgColor;
static UIColor *_selectedTextColor;
static CGRect _bgFillRect;
static CGRect _toFromAirportRect;
static CGRect _landingTimeRect;
static CGRect _statusRect;
static CGSize _shadowOffset;

+ (void)initialize {
    if (self == [FlightResultTableViewCell class]) {
        _toFromAirportFont = [UIFont systemFontOfSize:16.0f];
        _statusFont = [UIFont systemFontOfSize:11.0f];
        _landingTimeFont = [UIFont systemFontOfSize:11.0f];
        _toFromAirportColor = [UIColor blackColor];
        _landingTimeColor = [UIColor grayColor];
        _bgColor = [UIColor whiteColor];
        _selectedBgColor = [UIColor blueColor];
        _selectedTextColor = [UIColor whiteColor];
        _bgFillRect = CGRectMake(0.0f, 0.0f, FlightResultTableViewCellWidth, FlightResultTableViewCellHeight);
        _toFromAirportRect = CGRectMake(5.0f, 5.0f, 270.0f, 20.0f);
        _landingTimeRect = CGRectMake(5.0f, 30.0f, 195.0f, 20.0f);
        _statusRect = CGRectMake(205.0f, 30.0f, 70.0f, 20.0f);
        _shadowOffset = CGSizeMake(0.0f, 1.0f);
    }
}

- (void)setToAirport:(NSString *)anAirport {
    if (toAirport != anAirport) {
        toAirport = [anAirport copy];
        self._toFromAirport = [NSString stringWithFormat:@"%@ to %@", fromAirport, toAirport];
        [self setNeedsDisplay];
    }
}


- (void)setFromAirport:(NSString *)anAirport {
    if (fromAirport != anAirport) {
        fromAirport = [anAirport copy];
        self._toFromAirport = [NSString stringWithFormat:@"%@ to %@", fromAirport, toAirport];
        [self setNeedsDisplay];
    }
}


- (void)setStatus:(NSString *)aStatus {
    if (status != aStatus) {
        status = [aStatus copy];
        [self setNeedsDisplay];
    }
}


- (void)setStatusColor:(UIColor *)aStatusColor {
    if (statusColor != aStatusColor) {
        statusColor = [aStatusColor copy];
        [self setNeedsDisplay];
    }
}


- (void)setLandingTime:(NSString *)aLandingTime {
    if (landingTime != aLandingTime) {
        landingTime = [aLandingTime copy];
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
        [_toFromAirportColor set];
    }
    
    [_toFromAirport drawInRect:_toFromAirportRect 
                      withFont:_toFromAirportFont 
                 lineBreakMode:UILineBreakModeMiddleTruncation 
                     alignment:UITextAlignmentLeft];
    
    if (isHighlighted) {
        [_selectedTextColor set];
    }
    else {
        [_landingTimeColor set];
    }
    
    [landingTime drawInRect:_landingTimeRect 
                   withFont:_landingTimeFont 
              lineBreakMode:UILineBreakModeTailTruncation 
                  alignment:UITextAlignmentLeft];
    
    if (isHighlighted) {
        [_selectedTextColor set];
    }
    else {
        [statusColor set];
    }
    
    [status drawInRect:_statusRect
              withFont:_statusFont
         lineBreakMode:UILineBreakModeTailTruncation 
             alignment:UITextAlignmentRight];   
}

@end
