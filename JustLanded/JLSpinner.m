//
//  JLSpinner.m
//  JustLanded
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLSpinner.h"

@implementation JLSpinner

- (id)initWithFrame:(CGRect)frame {
    CGRect fixedSizeFrame = CGRectMake(frame.origin.x, frame.origin.y, 200.0f, 200.0f);
    
    self = [super initWithFrame:fixedSizeFrame];
    if (self) {
        self.animationDuration = 1.0;
        self.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"lookup"], nil];
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
