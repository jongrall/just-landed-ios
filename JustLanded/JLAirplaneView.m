//
//  JLAirplaneView.m
//  JustLanded
//
//  Created by Jon on 9/5/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLAirplaneView.h"

@interface JLAirplaneView ()

@property (strong, nonatomic) NSTimer *animationStartTimer_;
@property (strong, nonatomic) NSTimer *airplaneTimer_;
@property (strong, nonatomic) UIImageView *airplane_;

- (void)startAnimatingPlane;
- (void)animationTick;

@end


@implementation JLAirplaneView

@synthesize animationStartTimer_;
@synthesize airplaneTimer_;
@synthesize airplane_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        airplane_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plane_contrail"]];
        airplane_.frame = CGRectMake(-airplane_.image.size.width, // Place offscreen
                                     0.0f,
                                     airplane_.image.size.width, // Fixed width
                                     airplane_.image.size.height); // Fixed height
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:airplane_];
    }
    
    return self;
}


- (void)startAnimating {
    if (!self.animationStartTimer_ || ![self.animationStartTimer_ isValid]) {
        // Reset
        [self.airplane_ setFrame:CGRectMake(-self.airplane_.frame.size.width,
                                            self.airplane_.frame.origin.y,
                                            self.airplane_.frame.size.width,
                                            self.airplane_.frame.size.height)];
        
        [self.animationStartTimer_ invalidate];
        self.animationStartTimer_ = [NSTimer timerWithTimeInterval:(arc4random() % 15)
                                                 target:self
                                               selector:@selector(startAnimatingPlane)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.animationStartTimer_ forMode:NSRunLoopCommonModes];
    }
}


- (void)stopAnimating {
    [self.animationStartTimer_ invalidate];
    [self.airplaneTimer_ invalidate];
}


- (void)startAnimatingPlane {
    // Start the animation over only if the plane is in the reset position
    if (self.airplane_.frame.origin.x <= -self.airplane_.frame.size.width && (!self.airplaneTimer_ || ![self.airplaneTimer_ isValid])) {
        //Reset
        [self.airplaneTimer_ invalidate];
        self.airplaneTimer_ = [NSTimer timerWithTimeInterval:0.025
                                                      target:self
                                                    selector:@selector(animationTick)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.airplaneTimer_ forMode:NSRunLoopCommonModes];
    }
}


- (void)animationTick {
    CGFloat newOffset = airplane_.frame.origin.x + 0.3f;
    
    if (newOffset <= airplane_.frame.size.width) {
        [airplane_ setFrame:CGRectMake(newOffset,
                                            airplane_.frame.origin.y,
                                            airplane_.frame.size.width,
                                            airplane_.frame.size.height)];
    }
    else {
        [airplaneTimer_ invalidate];
        [airplane_ setFrame:CGRectMake(-airplane_.frame.size.width,
                                       airplane_.frame.origin.y,
                                       airplane_.frame.size.width,
                                       airplane_.frame.size.height)];
    }
}


- (void)dealloc {
    [animationStartTimer_ invalidate];
    [airplaneTimer_ invalidate];
}


@end
