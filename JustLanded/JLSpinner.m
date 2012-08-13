//
//  JLSpinner.m
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLSpinner.h"

@implementation JLSpinner

- (id)initWithFrame:(CGRect)frame {
    CGRect fixedSizeFrame = CGRectMake(frame.origin.x, frame.origin.y, 114.0f, 115.0f);
    
    self = [super initWithFrame:fixedSizeFrame];
    if (self) {
        self.animationDuration = 0.15;
        self.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"spinner_1"],
                                [UIImage imageNamed:@"spinner_2"],
                                [UIImage imageNamed:@"spinner_3"], nil];
    }
    return self;
}


- (void)startAnimating {
    [super startAnimating];
    self.hidden = NO;
}


- (void)stopAnimating {
    [super stopAnimating];
    self.hidden = YES;
}

@end
