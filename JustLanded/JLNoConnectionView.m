//
//  JLNoConnectionView.m
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLNoConnectionView.h"
#import "JLStyles.h"

@interface JLNoConnectionView ()

// Redefine as readwrite
@property (strong, readwrite, nonatomic) JLLabel *noConnectionLabel;
@property (strong, readwrite, nonatomic) JLButton *tryAgainbutton;

- (void)tryAgain;

@end


@implementation JLNoConnectionView

- (id)initWithFrame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        // Add background
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay_screens_bg"]];
        backgroundView.frame = aFrame;
 
        // Add no connection graphic
        UIImage *noConnImg = [UIImage imageNamed:@"no_connection" 
                                       withColor:nil 
                                     shadowColor:[UIColor whiteColor] 
                                    shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                      shadowBlur:0.0f];
        self.noConnectionImageView = [[UIImageView alloc] initWithImage:noConnImg];
        self.noConnectionImageView.frame = CGRectMake((aFrame.size.width - noConnImg.size.width) / 2.0f,
                                                      50.0f,
                                                      noConnImg.size.width,
                                                      noConnImg.size.height);
        
        // Add divider
        self.divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
        self.divider.frame = CGRectMake((320.0f - self.divider.frame.size.width) / 2.0f,
                                        343.0f,
                                        self.divider.frame.size.width,
                                        self.divider.frame.size.height);
        
        // Add label
        self.noConnectionLabel = [[JLLabel alloc] initWithLabelStyle:[JLStyles noConnectionLabelStyle] 
                                                               frame:CGRectMake((aFrame.size.width - 300.0f) / 2.0f,
                                                                                294.0f,
                                                                                300.0f,
                                                                                30.0f)];
        self.noConnectionLabel.text = NSLocalizedString(@"No Internet Connection", @"No Internet Connection");
        
        // Add retry button
        self.tryAgainbutton = [[JLButton alloc] initWithButtonStyle:[JLStyles defaultButtonStyle] 
                                                              frame:CGRectMake(10.0f,
                                                                               373.0f,
                                                                               aFrame.size.width - 20.0f,
                                                                               56.0f)];
        [self.tryAgainbutton addTarget:self
                                action:@selector(tryAgain) 
                      forControlEvents:UIControlEventTouchUpInside];
        [self.tryAgainbutton setTitle:NSLocalizedString(@"Try Again", @"Try Again") forState:UIControlStateNormal];
        
        [self addSubview:backgroundView];
        [self addSubview:self.noConnectionImageView];
        [self addSubview:self.noConnectionLabel];
        [self addSubview:self.divider];
        [self addSubview:self.tryAgainbutton];
    }
    return self;
}


- (void)tryAgain {
    self.tryAgainbutton.enabled = NO;
    [self.delegate tryConnectionAgain];
}

@end
