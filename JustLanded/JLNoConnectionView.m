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
@property (strong, readwrite, nonatomic) JLButton *tryAgainButton;

- (void)tryAgain;

@end


@implementation JLNoConnectionView

@synthesize noConnectionImageView = noConnectionImageView_;
@synthesize divider = divider_;
@synthesize noConnectionLabel = noConnectionLabel_;
@synthesize tryAgainButton = tryAgainButton_;

- (id)initWithFrame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        // Add background
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"overlay_screens_bg" imageName]]];
        backgroundView.frame = aFrame;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
 
        // Add no connection graphic
        UIImage *noConnImg = [UIImage imageNamed:@"no_connection" 
                                       withColor:nil 
                                     shadowColor:[UIColor whiteColor] 
                                    shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                      shadowBlur:0.0f];
        noConnectionImageView_ = [[UIImageView alloc] initWithImage:noConnImg];
        noConnectionImageView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        CGFloat noConnectionImageOriginY = [UIScreen isMainScreenWide] ? 90.0f : 50.0f;
        noConnectionImageView_.frame = CGRectMake((aFrame.size.width - noConnImg.size.width) / 2.0f,
                                                 noConnectionImageOriginY,
                                                 noConnImg.size.width,
                                                 noConnImg.size.height);
        
        // Add divider
        divider_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
        divider_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        CGFloat dividerOriginY = [UIScreen isMainScreenWide] ? 431.0f : 343.0f;
        divider_.frame = CGRectMake((320.0f - divider_.frame.size.width) / 2.0f,
                                    dividerOriginY,
                                    divider_.frame.size.width,
                                    divider_.frame.size.height);
        
        // Add label
        CGFloat noConnectionLabelOriginY = [UIScreen isMainScreenWide] ? 334.0f : 294.0f;
        noConnectionLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLStyles noConnectionLabelStyle]
                                                           frame:CGRectMake((aFrame.size.width - 300.0f) / 2.0f,
                                                                            noConnectionLabelOriginY,
                                                                            aFrame.size.width - 20.0f,
                                                                            30.0f)];
        noConnectionLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        noConnectionLabel_.text = NSLocalizedString(@"No Internet Connection", @"No Internet Connection");
        
        // Add retry button
        CGFloat tryAgainButtonOriginY = [UIScreen isMainScreenWide] ? 461.0f : 373.0f;
        tryAgainButton_ = [[JLButton alloc] initWithButtonStyle:[JLStyles defaultButtonStyle]
                                                          frame:CGRectMake(10.0f,
                                                                           tryAgainButtonOriginY,
                                                                           aFrame.size.width - 20.0f,
                                                                           56.0f)];
        tryAgainButton_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [tryAgainButton_ addTarget:self
                                action:@selector(tryAgain) 
                      forControlEvents:UIControlEventTouchUpInside];
        [tryAgainButton_ setTitle:NSLocalizedString(@"Try Again", @"Try Again") forState:UIControlStateNormal];
        
        [self addSubview:backgroundView];
        [self addSubview:noConnectionImageView_];
        [self addSubview:noConnectionLabel_];
        [self addSubview:divider_];
        [self addSubview:tryAgainButton_];
    }
    return self;
}


- (void)tryAgain {
    self.tryAgainButton.enabled = NO;
    id<NoConnectionDelegate> noConnectionDelegate = _delegate;
    [noConnectionDelegate tryConnectionAgain];
}

@end
