//
//  JLAirplaneView.m
//  JustLanded
//
//  Created by Jon on 9/5/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLAirplaneView.h"

@interface JLAirplaneView ()

@property (strong, nonatomic) NSTimer *_animationStartTimer;
@property (strong, nonatomic) NSTimer *_airplaneTimer;
@property (strong, nonatomic) UIImageView *_airplane;

- (void)startAnimatingPlane;
- (void)animationTick;

@end


@implementation JLAirplaneView

@synthesize _animationStartTimer;
@synthesize _airplaneTimer;
@synthesize _airplane;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _airplane = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plane_contrail"]];
        _airplane.frame = CGRectMake(-_airplane.image.size.width, // Place offscreen
                                0.0f,
                                _airplane.image.size.width, // Fixed width
                                _airplane.image.size.height); // Fixed height
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_airplane];
    }
    
    return self;
}


- (void)startAnimating {
    
    if (!_animationStartTimer || ![_animationStartTimer isValid]) {
        // Reset
        [_airplane setFrame:CGRectMake(-_airplane.frame.size.width,
                                       _airplane.frame.origin.y,
                                       _airplane.frame.size.width,
                                       _airplane.frame.size.height)];
        
        self._animationStartTimer = [NSTimer timerWithTimeInterval:(arc4random() % 30)
                                                 target:self
                                               selector:@selector(startAnimatingPlane)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_animationStartTimer forMode:NSRunLoopCommonModes];
    }
}


- (void)stopAnimating {
    [_animationStartTimer invalidate];
    [_airplaneTimer invalidate];
}


- (void)startAnimatingPlane {
    // Start the animation over only if the plane is in the reset position
    if (_airplane.frame.origin.x <= -_airplane.frame.size.width) {
        //Reset
        self._airplaneTimer = [NSTimer timerWithTimeInterval:0.025
                                                      target:self
                                                    selector:@selector(animationTick)
                                                    userInfo:nil
                                                    repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_airplaneTimer forMode:NSRunLoopCommonModes];
    }
}


- (void)animationTick {
    CGFloat newOffset = _airplane.frame.origin.x + 0.3f;
    
    if (newOffset <= _airplane.frame.size.width) {
        [_airplane setFrame:CGRectMake(newOffset,
                                       _airplane.frame.origin.y,
                                       _airplane.frame.size.width,
                                       _airplane.frame.size.height)];
    }
    else {
        [_airplaneTimer invalidate];
        [_airplane setFrame:CGRectMake(-_airplane.frame.size.width,
                                       _airplane.frame.origin.y,
                                       _airplane.frame.size.width,
                                       _airplane.frame.size.height)];
    }
}


- (void)dealloc {
    [_animationStartTimer invalidate];
    [_airplaneTimer invalidate];
}


@end
