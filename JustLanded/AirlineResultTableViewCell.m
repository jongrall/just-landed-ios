//
//  AirlineResultTableViewCell.m
//  Just Landed
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "AirlineResultTableViewCell.h"

CGFloat const AirlineResultCellHeight = 44.0f;
CGRect const textRect_ = {{14.0f, 14.0f}, {292.0f, 22.0f}};

@implementation AirlineResultTableViewCell

@synthesize airlineName = airlineName_;
@synthesize airlineCode = airlineCode_;
@synthesize clearText = clearText_;
@synthesize clearCell = clearCell_;

static UIFont *sNameFont_;
static UIFont *sCodeFont_;
static UIFont *sClearFont_;
static UIColor *sSelectedCellBackgroundColor_;
static UIColor *sCellBackgroundColor_;
static UIColor *sTextColor_;
static UIColor *sClearTextColor_;
static UIColor *sSelectedTextColor_;

+ (void)initialize {
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        if (self == [AirlineResultTableViewCell class]) {
            sNameFont_ = [JLStyles sansSerifLightOfSize:18.0f];
            sCodeFont_ = [JLStyles sansSerifLightBoldOfSize:18.0f];
            sClearFont_ = [JLStyles sansSerifLightBoldOfSize:18.0f];
            sSelectedCellBackgroundColor_ = [UIColor colorWithRed:107.0f/255.0f green:157.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
            sCellBackgroundColor_ = [UIColor whiteColor];
            sTextColor_ = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
            sSelectedTextColor_ = [UIColor whiteColor];
            sClearTextColor_ = [UIColor colorWithRed:107.0f/255.0f green:157.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
        }
    });
}


- (UIEdgeInsets)separatorInset {
    return UIEdgeInsetsZero;
}


- (void)setAirlineName:(NSString *)aName {
    if (airlineName_ != aName) {
        airlineName_ = [aName stringByAppendingString:@" "];
        [self setNeedsDisplay];
    }
}


- (void)setAirlineCode:(NSString *)anAirlineCode {
    if (airlineCode_ != anAirlineCode) {
        airlineCode_ = [NSString stringWithFormat:@"(%@)", anAirlineCode];
        [self setNeedsDisplay];
    }
}

- (void)setClearText:(NSString *)someText {
    if (clearText_ != someText) {
        clearText_ = [someText copy];
        [self setNeedsDisplay];
    }
}

- (void)setClearCell:(BOOL)flag {
    if (clearCell_ != flag) {
        clearCell_ = flag;
        [self setNeedsDisplay];
    }
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)isHighlighted {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the bg
    if (isHighlighted) {
        [sSelectedCellBackgroundColor_ set];
    }
    else {
        [sCellBackgroundColor_ set];
    }
    
    CGContextFillRect(context, rect);
    
    if (isHighlighted) {
        [sSelectedTextColor_ set];
    }
    else {
        if (clearCell_) {
            [sClearTextColor_ set];
        }
        else {
            [sTextColor_ set];
        }
    }
    
    if (!clearCell_) {
        // Draw the text
        CGSize nameSize = [airlineName_ drawInRect:textRect_
                                          withFont:sNameFont_
                                     lineBreakMode:NSLineBreakByTruncatingMiddle
                                         alignment:NSTextAlignmentLeft];
        [airlineCode_ drawInRect:CGRectMake(textRect_.origin.x + nameSize.width,
                                            textRect_.origin.y,
                                            textRect_.size.width - nameSize.width,
                                            textRect_.size.height)
                        withFont:sCodeFont_
                   lineBreakMode:NSLineBreakByTruncatingTail
                       alignment:NSTextAlignmentLeft];
    }
    else {
        [clearText_ drawInRect:textRect_
                      withFont:sClearFont_
                 lineBreakMode:NSLineBreakByTruncatingTail
                     alignment:NSTextAlignmentCenter];
    }
}

@end
