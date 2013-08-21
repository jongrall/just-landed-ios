//
//  JLLeaveMeter.m
//  Just Landed
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLeaveMeter.h"

@interface JLLeaveMeter  ()

@property (strong, nonatomic) UIImage *foreground_;
@property (strong, nonatomic) UIImage *backgroundShadow_;
@property (strong, nonatomic) UIImage *meterGradient_;
@property (strong, nonatomic) JLMultipartOverUnderLabel *largeTimeLabel_;
@property (strong, nonatomic) JLMultipartOverUnderLabel *smallTimeLabel_;
@property (strong, nonatomic) JLLabel *leaveInstructionsLabel_;
@property (strong, nonatomic) JLMultipartOverUnderLabel *leaveNowLabel_;

@end

@implementation JLLeaveMeter

@synthesize timeRemaining = timeRemaining_;
@synthesize meterMaxTimeRemaining = meterMaxTimeRemaining_;
@synthesize showEmptyMeter = showEmptyMeter_;
@synthesize foreground_;
@synthesize backgroundShadow_;
@synthesize meterGradient_;
@synthesize largeTimeLabel_;
@synthesize smallTimeLabel_;
@synthesize leaveInstructionsLabel_;
@synthesize leaveNowLabel_;

- (id)initWithFrame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        foreground_ = [UIImage imageNamed:@"gauge_top"];
        backgroundShadow_ = [UIImage imageNamed:@"gauge_inset"];
        meterGradient_ = [UIImage imageNamed:@"gauge_gradient"];
        
        CGPoint leaveInValueOrigin = [JLTrackStyles leaveInValueOrigin];
        largeTimeLabel_ = [[JLMultipartOverUnderLabel alloc] initWithLabelStyles:@[[JLTrackStyles leaveTimeLargeLabelStyle],
                                                                                       [JLTrackStyles leaveTimeLargeUnitStyle]]
                                                                           frame:CGRectMake(leaveInValueOrigin.x,
                                                                                            leaveInValueOrigin.y,
                                                                                            aFrame.size.width,
                                                                                            100.0f)];
        largeTimeLabel_.offsets = @[[NSValue valueWithCGSize:CGSizeMake(0.0f, -14.0f)],
                                   [NSValue valueWithCGSize:CGSizeMake(0.0f, 58.0f)]];
        largeTimeLabel_.hidden = YES;
        
        smallTimeLabel_ = [[JLMultipartOverUnderLabel alloc] initWithLabelStyles:@[[JLTrackStyles leaveTimeSmallLabelStyle],
                                                                                       [JLTrackStyles leaveTimeSmallUnitStyle],
                                                                                       [JLTrackStyles leaveTimeSmallLabelStyle],
                                                                                       [JLTrackStyles leaveTimeSmallUnitStyle]]
                                                                           frame:CGRectMake(leaveInValueOrigin.x,
                                                                                            leaveInValueOrigin.y,
                                                                                            aFrame.size.width,
                                                                                            120.0f)];
        smallTimeLabel_.offsets = @[[NSValue valueWithCGSize:CGSizeMake(0.0f, 8.0f)],
                                        [NSValue valueWithCGSize:CGSizeMake(0.0f, 46.0f)],
                                        [NSValue valueWithCGSize:CGSizeMake(0.0f, 8.0f)],
                                        [NSValue valueWithCGSize:CGSizeMake(0.0f, 46.0f)]];
        smallTimeLabel_.labelSeparation = 12.0f;
        smallTimeLabel_.hidden = YES;
        
        CGPoint leaveInInstructionsOrigin = [JLTrackStyles leaveInInstructionsOrigin];
        leaveInstructionsLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLTrackStyles leaveInstructionsLabelStyle] 
                                                                     frame:CGRectMake(leaveInInstructionsOrigin.x,
                                                                                      leaveInInstructionsOrigin.y,
                                                                                      aFrame.size.width,
                                                                                      80.0f)];
        
        leaveInstructionsLabel_.text = NSLocalizedString(@"YOU SHOULD\nLEAVE IN", @"Leave Instructions Label");
        leaveInstructionsLabel_.hidden = YES;
        
        CGPoint leaveNowOrigin = [JLTrackStyles leaveNowOrigin];
        leaveNowLabel_ = [[JLMultipartOverUnderLabel alloc] initWithLabelStyles:@[[JLTrackStyles leaveNowStyle],
                                                                                      [JLTrackStyles leaveNowStyle]] 
                                                                               frame:CGRectMake(leaveNowOrigin.x,
                                                                                                leaveNowOrigin.y,
                                                                                                aFrame.size.width,
                                                                                                200.0f)];
        
        leaveNowLabel_.parts = @[@"LEAVE", @"NOW"];
        leaveNowLabel_.offsets = @[[NSValue valueWithCGSize:CGSizeMake(0.5f, 0.0f)],
                                  [NSValue valueWithCGSize:CGSizeMake(0.5f, 25.0f)]];
        leaveNowLabel_.hidden = YES;

        [self addSubview:largeTimeLabel_];
        [self addSubview:smallTimeLabel_];
        [self addSubview:leaveInstructionsLabel_];
        [self addSubview:leaveNowLabel_];
        self.opaque = NO;
    }
    return self;
}


- (void)setTimeRemaining:(NSTimeInterval)newTime {
    newTime = (newTime > 0.0) ? newTime : 0.0; // Time remaining is 0.0 or greater
    
    BOOL needsRedraw = fabs(timeRemaining_ - newTime) > 60.0; // Only redraw meter every 60s
    
    if (self.meterMaxTimeRemaining == 0.0 || self.meterMaxTimeRemaining <= newTime) { // Only set this the first time or if the time remaining increases
        double maxTimeLeft = ceil(newTime / 3600.0) * 3600.0; // Max is next largest whole number of hours
        self.meterMaxTimeRemaining = maxTimeLeft;
        needsRedraw = YES;
    }
    
    timeRemaining_ = newTime;
    NSString *timeRemainingString = [NSDate timeIntervalToShortUnitString:newTime leadingZeros:YES];
    NSArray *parts = [timeRemainingString componentsSeparatedByString:@" "];
    
    if ([parts count] > 4) { // No more than 4 parts
        parts = [parts subarrayWithRange:NSMakeRange(0, 4)]; 
    }
    
    if (!showEmptyMeter_) {
        if (newTime >= 1.0 && [parts count] == 2) {
            // When showing 2 parts, no leading zeros
            parts = [[NSDate timeIntervalToShortUnitString:newTime leadingZeros:NO] componentsSeparatedByString:@" "];
            self.largeTimeLabel_.parts = parts;
            self.largeTimeLabel_.hidden = NO;
            self.smallTimeLabel_.hidden = YES;
            self.leaveInstructionsLabel_.hidden = NO;
            self.leaveNowLabel_.hidden = YES;
        }
        else if (newTime >= 1.0 && [parts count] == 4) {
            self.smallTimeLabel_.parts = parts;
            self.smallTimeLabel_.hidden = NO;
            self.largeTimeLabel_.hidden = YES;
            self.leaveInstructionsLabel_.hidden = NO;
            self.leaveNowLabel_.hidden = YES;
        }
        else {
            self.leaveNowLabel_.hidden = NO;
            self.smallTimeLabel_.hidden = YES;
            self.largeTimeLabel_.hidden = YES;
            self.leaveInstructionsLabel_.hidden = YES;
        }
    }
    
    if (needsRedraw) {
        [self setNeedsDisplay];
    }
}


- (void)setMeterMaxTimeRemaining:(NSTimeInterval)maxTime {
    meterMaxTimeRemaining_ = maxTime;
    [self setNeedsDisplay];
}


- (void)setShowEmptyMeter:(BOOL)flag {
    showEmptyMeter_ = flag;
    
    if (showEmptyMeter_) {
        self.leaveInstructionsLabel_.hidden = YES;
        self.leaveNowLabel_.hidden = YES;
        self.largeTimeLabel_.hidden = YES;
        self.smallTimeLabel_.hidden = YES;
    }
    else {
        [self setTimeRemaining:self.timeRemaining];
    }
    
    // Redraw
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    // Custom drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    // Draw the background shadow
    [backgroundShadow_ drawInRect:rect];
    
    if (!showEmptyMeter_) {
        // Calculate the % of the meter to show
        double meterFillFraction = fabs(timeRemaining_) / meterMaxTimeRemaining_;
        
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
                                                        startAngle:(CGFloat) (130.0f * M_PI / 180.0f) // Slight buffer added
                                                          endAngle:(CGFloat) ((130.0f * M_PI / 180.0f) + ((rotationDegrees + 25.0f) * M_PI / 180.0f))
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
                                          startAngle:(CGFloat) (135.0f * M_PI / 180.0f)
                                            endAngle:(CGFloat) ((135.0f * M_PI / 180.0f) + (rotationDegrees * M_PI / 180.0f))
                                           clockwise:YES];
        [path addLineToPoint:CGPointMake(rect.size.width / 2.0f, rect.size.width / 2.0f)];
        [path closePath];
        [path addClip];
        [meterGradient_ drawInRect:rect];
        CGContextRestoreGState(context);
    }
    
    // Draw the foreground
    [foreground_ drawInRect:rect];
    
    [super drawRect:rect];
}

@end
