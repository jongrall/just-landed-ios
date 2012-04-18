//
//  JLLeaveMeter.m
//  JustLanded
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLLeaveMeter.h"

@interface JLLeaveMeter  () {
    __strong UIImage *_background;
    __strong UIImage *_gaugeOffShadow;
    __strong UIImage *_gaugeOnShadow;
    __strong UIImage *_gaugeOff;
    __strong UIImage *_gaugeOn;
    __strong JLLabel *_leaveTimeValueLabel;
    __strong JLLabel *_leaveTimeUnitLabel;
    __strong JLLabel *_leaveInstructionsLabel;
    __strong JLLabel *_leaveNowLabel;
}

@end

@implementation JLLeaveMeter 

@synthesize timeRemaining;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _background = [UIImage imageNamed:@"gauge_bg"];
        _gaugeOffShadow = [UIImage imageNamed:@"gauge_shadow_off"];
        _gaugeOnShadow = [UIImage imageNamed:@"gauge_shadow_on"];
        _gaugeOff = [UIImage imageNamed:@"gauge_off"];
        _gaugeOn = [UIImage imageNamed:@"gauge_on"];
        
        _leaveTimeValueLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles leaveTimeLabelStyle] 
                                                             frame:CGRectMake(LEAVE_IN_VALUE_ORIGIN.x,
                                                                              LEAVE_IN_VALUE_ORIGIN.y,
                                                                              frame.size.width,
                                                                              100.0f)];
        
        _leaveTimeUnitLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles leaveTimeUnitStyle] 
                                                            frame:CGRectMake(LEAVE_IN_UNIT_ORIGIN.x,
                                                                             LEAVE_IN_UNIT_ORIGIN.y,
                                                                             frame.size.width, 30.0f)];
        
        _leaveInstructionsLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles leaveInstructionsLabelStyle] 
                                                               frame:CGRectMake(LEAVE_IN_INSTRUCTIONS_ORIGIN.x,
                                                                                LEAVE_IN_INSTRUCTIONS_ORIGIN.y,
                                                                                frame.size.width,
                                                                                80.0f)];
        
        _leaveInstructionsLabel.text = NSLocalizedString(@"You Should\nLeave In", @"Leave Instructions Label");
        
        _leaveNowLabel = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles leaveNowStyle] 
                                                       frame:CGRectMake(LEAVE_NOW_ORIGIN.x,
                                                                        LEAVE_NOW_ORIGIN.y,
                                                                        frame.size.width,
                                                                        200.0f)];
        _leaveNowLabel.text = NSLocalizedString(@"LEAVE\nNOW", @"LEAVE\nNOW");
        _leaveNowLabel.hidden = YES;
        
        [self addSubview:_leaveTimeValueLabel];
        [self addSubview:_leaveTimeUnitLabel];
        [self addSubview:_leaveInstructionsLabel];
        [self addSubview:_leaveNowLabel];
        self.opaque = NO;
    }
    return self;
}


- (void)setTimeRemaining:(NSTimeInterval)newTime {
    timeRemaining = newTime;
    
    if (newTime <= 0.0) {
        _leaveTimeValueLabel.hidden = YES;
        _leaveTimeUnitLabel.hidden = YES;
        _leaveInstructionsLabel.hidden = YES;
    }
    else {
        _leaveNowLabel.hidden = YES;
        _leaveTimeValueLabel.hidden = NO;
        _leaveTimeUnitLabel.hidden = NO;
        _leaveInstructionsLabel.hidden = NO;
    }

    // Update the labels
    if (newTime <= 0.0) {
        _leaveNowLabel.hidden = NO;
    }
    else if (newTime < 60.0) {
        _leaveTimeValueLabel.text = [NSString stringWithFormat:@"%d", (int) newTime];
        _leaveTimeUnitLabel.text = @"SEC";
        _leaveInstructionsLabel.text = NSLocalizedString(@"YOU SHOULD\nLEAVE IN", @"Leave Instructions Label");
    }
    else if (newTime < 3600.0) {
        NSUInteger minutes = (int) ceil(newTime/60.0);
        _leaveTimeValueLabel.text = [NSString stringWithFormat:@"%d", minutes];
        _leaveTimeUnitLabel.text = @"MIN";
        _leaveInstructionsLabel.text = NSLocalizedString(@"YOU SHOULD\nLEAVE IN", @"Leave Instructions Label");
    }
    else if (newTime < 86400.0) {
        NSUInteger hours = (int) newTime / 3600.0;
        _leaveTimeValueLabel.text = [NSString stringWithFormat:@"~%d", hours];
        _leaveTimeUnitLabel.text = (hours == 1) ? @"HR" : @"HRS";
        _leaveInstructionsLabel.text = NSLocalizedString(@"YOU SHOULD\nLEAVE IN", @"Leave Instructions Label");
    }
    else if (newTime >= 86400.0) {
        NSUInteger days = (int) newTime / 86400.0;
        _leaveTimeValueLabel.text = [NSString stringWithFormat:@"~%d", days];
        _leaveTimeUnitLabel.text = (days == 1) ? @"DAY" : @"DAYS";
        _leaveInstructionsLabel.text = NSLocalizedString(@"YOU SHOULD\nLEAVE IN", @"Leave Instructions Label");
    }
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    [_background drawInRect:rect];
    
    // Only draw the meter if there's time remaining
    if (timeRemaining > 0.0) {
        [_gaugeOnShadow drawInRect:rect];
        [_gaugeOn drawInRect:rect];
    }
    
    [super drawRect:rect];
}

@end
