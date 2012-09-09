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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.airplane_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plane_contrail"]];
        self.airplane_.frame = CGRectMake(-self.airplane_.image.size.width, // Place offscreen
                                0.0f,
                                self.airplane_.image.size.width, // Fixed width
                                self.airplane_.image.size.height); // Fixed height
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.airplane_];
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
        
        self.animationStartTimer_ = [NSTimer timerWithTimeInterval:(arc4random() % 30)
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
    if (self.airplane_.frame.origin.x <= -self.airplane_.frame.size.width) {
        //Reset
        self.airplaneTimer_ = [NSTimer timerWithTimeInterval:0.025
                                                      target:self
                                                    selector:@selector(animationTick)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.airplaneTimer_ forMode:NSRunLoopCommonModes];
    }
}


- (void)animationTick {
    CGFloat newOffset = self.airplane_.frame.origin.x + 0.3f;
    
    if (newOffset <= self.airplane_.frame.size.width) {
        [self.airplane_ setFrame:CGRectMake(newOffset,
                                            self.airplane_.frame.origin.y,
                                            self.airplane_.frame.size.width,
                                            self.airplane_.frame.size.height)];
    }
    else {
        [self.airplaneTimer_ invalidate];
        [self.airplane_ setFrame:CGRectMake(-self.airplane_.frame.size.width,
                                            self.airplane_.frame.origin.y,
                                            self.airplane_.frame.size.width,
                                            self.airplane_.frame.size.height)];
    }
}


- (void)dealloc {
    [self.animationStartTimer_ invalidate];
    [self.airplaneTimer_ invalidate];
}


@end
