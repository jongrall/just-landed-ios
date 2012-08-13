//
//  JLNoConnectionView.m
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLNoConnectionView.h"
#import "JLStyles.h"

@interface JLNoConnectionView () {
    __strong UIImageView *_noConnectionView;
    __strong JLButton *_retryButton;
    __strong JLLabel *_noConnectionLabel;
}

- (void)tryAgain;

@end


@implementation JLNoConnectionView

@synthesize delegate;
@synthesize noConnectionImageView=_noConnectionView;
@synthesize noConnectionText;
@synthesize divider;
@synthesize tryAgainbutton=_retryButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        // Add background
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay_screens_bg"]];
        bgView.frame = frame;
 
        // Add no connection graphic
        UIImage *noConnImg = [UIImage imageNamed:@"no_connection" 
                                       withColor:nil 
                                     shadowColor:[UIColor whiteColor] 
                                    shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                      shadowBlur:0.0f];
        _noConnectionView = [[UIImageView alloc] initWithImage:noConnImg];
        _noConnectionView.frame = CGRectMake((frame.size.width - noConnImg.size.width) / 2.0f,
                                             50.0f,
                                             noConnImg.size.width,
                                             noConnImg.size.height);
        
        // Add divider
        self.divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
        self.divider.frame = CGRectMake((320.0f - divider.frame.size.width) / 2.0f,
                                   343.0f,
                                   divider.frame.size.width,
                                   divider.frame.size.height);
        
        // Add label
        _noConnectionLabel = [[JLLabel alloc] initWithLabelStyle:[JLStyles noConnectionLabelStyle] 
                                                           frame:CGRectMake((frame.size.width - 300.0f) / 2.0f,
                                                                            294.0f,
                                                                            300.0f,
                                                                            30.0f)];
        _noConnectionLabel.text = NSLocalizedString(@"No Internet Connection", @"No Internet Connection");
        
        // Add retry button
        _retryButton = [[JLButton alloc] initWithButtonStyle:[JLStyles defaultButtonStyle] 
                                                       frame:CGRectMake(10.0f,
                                                                        373.0f,
                                                                        frame.size.width - 20.0f,
                                                                        56.0f)];
        [_retryButton addTarget:self
                         action:@selector(tryAgain) 
               forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setTitle:NSLocalizedString(@"Try Again", @"Try Again") forState:UIControlStateNormal];
        
        [self addSubview:bgView];
        [self addSubview:_noConnectionView];
        [self addSubview:_noConnectionLabel];
        [self addSubview:divider];
        [self addSubview:_retryButton];
    }
    return self;
}


- (void)setNoConnectionText:(NSString *)text {
    _noConnectionLabel.text = text;
}

- (void)tryAgain {
    _retryButton.enabled = NO;
    [delegate tryConnectionAgain];
}

@end
