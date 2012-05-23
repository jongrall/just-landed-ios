//
//  JLLeaveMeter.m
//  JustLanded
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLeaveMeter.h"

@interface JLLeaveMeter  () {
    __strong UIImage *_foreground;
    __strong UIImage *_backgroundShadow;
    __strong UIImage *_meterGradient;
    __strong JLMultipartOverUnderLabel *_largeTimeLabel;
    __strong JLMultipartOverUnderLabel *_smallTimeLabel;
    __strong JLLabel *_leaveInstructionsLabel;
    __strong JLMultipartOverUnderLabel *_leaveNowLabel;
}

@end

@implementation JLLeaveMeter 

@synthesize timeRemaining;
@synthesize meterMaxTimeRemaining;
@synthesize showEmptyMeter;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _foreground = [UIImage imageNamed:@"gauge_top"];
        _backgroundShadow = [UIImage imageNamed:@"gauge_inset"];
        _meterGradient = [UIImage imageNamed:@"gauge_gradient"];
        
        _largeTimeLabel = [[JLMultipartOverUnderLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles leaveTimeLargeLabelStyle],
                                                                                  [JLTrackStyles leaveTimeLargeUnitStyle], nil]
                                                                           frame:CGRectMake(LEAVE_IN_VALUE_ORIGIN.x,
                                                                                            LEAVE_IN_VALUE_ORIGIN.y,
                                                                                            frame.size.width,
                                                                                            100.0f)];
        _largeTimeLabel.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeMake(0.0f, -14.0f)],
                                   [NSValue valueWithCGSize:CGSizeMake(0.0f, 58.0f)], nil];
        _largeTimeLabel.hidden = YES;
        
        _smallTimeLabel = [[JLMultipartOverUnderLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles leaveTimeSmallLabelStyle],
                                                                                  [JLTrackStyles leaveTimeSmallUnitStyle],
                                                                                  [JLTrackStyles leaveTimeSmallLabelStyle],
                                                                                  [JLTrackStyles leaveTimeSmallUnitStyle], nil]
                                                                           frame:CGRectMake(LEAVE_IN_VALUE_ORIGIN.x,
                                                                                            LEAVE_IN_VALUE_ORIGIN.y,
                                                                                            frame.size.width,
                                                                                            120.0f)];
        _smallTimeLabel.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeMake(0.0f, 8.0f)],
                                   [NSValue valueWithCGSize:CGSizeMake(0.0f, 46.0f)],
                                   [NSValue valueWithCGSize:CGSizeMake(0.0f, 8.0f)],
                                   [NSValue valueWithCGSize:CGSizeMake(0.0f, 46.0f)], nil];
        _smallTimeLabel.labelSeparation = 12.0f;
        _smallTimeLabel.hidden = YES;
        
        _leaveInstructionsLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles leaveInstructionsLabelStyle] 
                                                               frame:CGRectMake(LEAVE_IN_INSTRUCTIONS_ORIGIN.x,
                                                                                LEAVE_IN_INSTRUCTIONS_ORIGIN.y,
                                                                                frame.size.width,
                                                                                80.0f)];
        
        _leaveInstructionsLabel.text = NSLocalizedString(@"YOU SHOULD\nLEAVE IN", @"Leave Instructions Label");
        _leaveInstructionsLabel.hidden = YES;
        
        _leaveNowLabel = [[JLMultipartOverUnderLabel alloc] initWithLabelStyles:[NSArray arrayWithObjects:[JLTrackStyles leaveNowStyle],
                                                                                 [JLTrackStyles leaveNowStyle], nil] 
                                                                          frame:CGRectMake(LEAVE_NOW_ORIGIN.x,
                                                                                           LEAVE_NOW_ORIGIN.y,
                                                                                           frame.size.width,
                                                                                           200.0f)];
        
        _leaveNowLabel.parts = [NSArray arrayWithObjects:@"LEAVE", @"NOW", nil];
        _leaveNowLabel.offsets = [NSArray arrayWithObjects:[NSValue valueWithCGSize:CGSizeMake(0.5f, 0.0f)],
                                  [NSValue valueWithCGSize:CGSizeMake(0.5f, 25.0f)], nil];
        _leaveNowLabel.hidden = YES;

        [self addSubview:_largeTimeLabel];
        [self addSubview:_smallTimeLabel];
        [self addSubview:_leaveInstructionsLabel];
        [self addSubview:_leaveNowLabel];
        self.opaque = NO;
    }
    return self;
}


- (void)setTimeRemaining:(NSTimeInterval)newTime {
    newTime = (newTime > 0.0) ? newTime : 0.0; // Time remaining is 0.0 or greater
    
    BOOL needsRedraw = fabs(timeRemaining - newTime) > 60.0; // Only redraw meter every 60s
    
    if (meterMaxTimeRemaining == 0.0) { // Only set this the first time
        double maxTimeLeft = ceil(newTime / 3600.0) * 3600.0; // Max is next largest whole number of hours
        self.meterMaxTimeRemaining = maxTimeLeft;
        needsRedraw = YES;
    }
    
    timeRemaining = newTime;
    NSString *timeRemainingString = [NSDate timeIntervalToShortUnitString:newTime leadingZeros:YES];
    NSArray *parts = [timeRemainingString componentsSeparatedByString:@" "];
    
    if ([parts count] > 4) { // No more than 4 parts
        parts = [parts subarrayWithRange:NSMakeRange(0, 4)]; 
    }
    
    if (newTime >= 1.0 && [parts count] == 2) {
        // When showing 2 parts, no leading zeros
        parts = [[NSDate timeIntervalToShortUnitString:newTime leadingZeros:NO] componentsSeparatedByString:@" "];
        _largeTimeLabel.parts = parts;
        _largeTimeLabel.hidden = NO;
        _smallTimeLabel.hidden = YES;
        _leaveInstructionsLabel.hidden = NO;
        _leaveNowLabel.hidden = YES;
    }
    else if (newTime >= 1.0 && [parts count] == 4) {
        _smallTimeLabel.parts = parts;
        _smallTimeLabel.hidden = NO;
        _largeTimeLabel.hidden = YES;
        _leaveInstructionsLabel.hidden = NO;
        _leaveNowLabel.hidden = YES;
    }
    else {
        _leaveNowLabel.hidden = NO;
        _smallTimeLabel.hidden = YES;
        _largeTimeLabel.hidden = YES;
        _leaveInstructionsLabel.hidden = YES;
    }

    _leaveInstructionsLabel.text = NSLocalizedString(@"YOU SHOULD\nLEAVE IN", @"Leave Instructions Label");
    
    if (needsRedraw) {
        [self setNeedsDisplay];
    }
}


- (void)setMeterMaxTimeRemaining:(NSTimeInterval)maxTime {
    meterMaxTimeRemaining = maxTime;
    [self setNeedsDisplay];
}


- (void)setShowEmptyMeter:(BOOL)flag {
    showEmptyMeter = flag;
    
    if (showEmptyMeter) {
        _leaveInstructionsLabel.hidden = YES;
        _leaveNowLabel.hidden = YES;
        _largeTimeLabel.hidden = YES;
        _smallTimeLabel.hidden = YES;
    }
    else {
        // Redraw
        [self setTimeRemaining:timeRemaining];
    }
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    // Draw the background shadow
    [_backgroundShadow drawInRect:rect];
    
    if (!showEmptyMeter) {
        // Calculate the % of the meter to show
        double meterFillFraction = fabs(timeRemaining) / meterMaxTimeRemaining;
        
        // Calculate the rotation amount for the meter image
        double rotationDegrees = 270.0 * meterFillFraction;
        
        UIImage *meterImage = [UIImage imageNamed:@"gauge_color" 
                          rotatedDegreesClockwise:(rotationDegrees - 270.0)
                                      shadowColor:[UIColor colorWithRed:205.0f/255.0f green:63.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
                                     shadowOffset:CGSizeMake(0.0f, 2.0f) 
                                       shadowBlur:0.0f];
        
        // Draw the meter (clipped to the section that should be visible)
        CGContextSaveGState(context);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f) 
                                                            radius:rect.size.width / 2.0f
                                                        startAngle:(130.0f * M_PI / 180.0f) // Slight buffer added
                                                          endAngle:((130.0f * M_PI / 180.0f) + ((rotationDegrees + 25.0f) * M_PI / 180.0f))
                                                         clockwise:YES];
        [path addLineToPoint:CGPointMake(rect.size.width / 2.0f, rect.size.width / 2.0f)];
        [path closePath];
        [path addClip];
        [meterImage drawInRect:rect];
        CGContextRestoreGState(context);
        
        CGContextSaveGState(context);
        // Change clip path slightly
        path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f) 
                                                            radius:rect.size.width / 2.0f
                                                        startAngle:(135.0f * M_PI / 180.0f)
                                                          endAngle:((135.0f * M_PI / 180.0f) + (rotationDegrees * M_PI / 180.0f))
                                                         clockwise:YES];
        [path addLineToPoint:CGPointMake(rect.size.width / 2.0f, rect.size.width / 2.0f)];
        [path closePath];
        [path addClip];
        [_meterGradient drawInRect:rect];
        CGContextRestoreGState(context);
    }
    
    // Draw the foreground
    [_foreground drawInRect:rect];
    
    [super drawRect:rect];
}

@end
