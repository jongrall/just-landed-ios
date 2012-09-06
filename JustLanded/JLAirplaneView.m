//
//  JLAirplaneView.m
//  JustLanded
//
//  Created by Jon on 9/5/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLAirplaneView.h"

@interface JLAirplaneView ()

@property (strong, nonatomic) NSTimer *_airplaneTimer;
@property (strong, nonatomic) UIImageView *_airplane;

@end


@implementation JLAirplaneView

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
    if (!_airplaneTimer || ![_airplaneTimer isValid]) {
        // Reset
        [_airplane setFrame:CGRectMake(-_airplane.frame.size.width,
                                       _airplane.frame.origin.y,
                                       _airplane.frame.size.width,
                                       _airplane.frame.size.height)];
        
        _airplaneTimer = [NSTimer timerWithTimeInterval:(arc4random() % 30)
                                                 target:self
                                               selector:@selector(animatePlane)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_airplaneTimer forMode:NSRunLoopCommonModes];
    }
}


- (void)stopAnimating {
    [_airplaneTimer invalidate];
}


- (void)animatePlane {
    // Start the animation over only if the plane is in the reset position
    if (_airplane.frame.origin.x <= -_airplane.frame.size.width) {
        //Reset
        [UIView animateWithDuration:120.0
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             [_airplane setFrame:CGRectMake(_airplane.frame.size.width,
                                                            _airplane.frame.origin.y,
                                                            _airplane.frame.size.width,
                                                            _airplane.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [_airplane setFrame:CGRectMake(-_airplane.frame.size.width,
                                                                _airplane.frame.origin.y,
                                                                _airplane.frame.size.width,
                                                                _airplane.frame.size.height)];
                             }
                         }];
    }
}


- (void)dealloc {
    [_airplaneTimer invalidate];
}


@end
