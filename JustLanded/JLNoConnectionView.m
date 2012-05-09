//
//  JLNoConnectionView.m
//  JustLanded
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
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
@synthesize noConnectionImage;
@synthesize noConnectionText;
@synthesize tryAgainbutton=_retryButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // Add background
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracking_footer_bg"]];
        bgView.frame = frame;
   
        // Add no connection graphic
        UIImage *noConnImg = [UIImage imageNamed:@"faq"];
        _noConnectionView = [[UIImageView alloc] initWithImage:noConnImg];
        _noConnectionView.frame = CGRectMake((frame.size.width - noConnImg.size.width) / 2.0f,
                                             (frame.size.height - noConnImg.size.height) / 2.0f - 100.0f,
                                             noConnImg.size.width,
                                             noConnImg.size.height);
        
        
        // Add label
        _noConnectionLabel = [[JLLabel alloc] initWithLabelStyle:[JLStyles noConnectionLabelStyle] 
                                                           frame:CGRectMake((frame.size.width - 200.0f) / 2.0f,
                                                                            ((frame.size.height - 30.0f) / 2.0f) - 150.0f,
                                                                            200.0f,
                                                                            30.0f)];
        _noConnectionLabel.text = NSLocalizedString(@"No Internet Connection", @"No Internet Connection");
        
        // Add retry button
        _retryButton = [[JLButton alloc] initWithButtonStyle:[JLStyles defaultButtonStyle] 
                                                       frame:CGRectMake(10.0f,
                                                                        (frame.size.height - 56.0f) / 2.0f,
                                                                        frame.size.width - 20.0f,
                                                                        56.0f)];
        [_retryButton addTarget:self
                         action:@selector(tryAgain) 
               forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setTitle:NSLocalizedString(@"Try Again", @"Try Again") forState:UIControlStateNormal];
        
        [self addSubview:bgView];
        [self addSubview:_noConnectionView];
        [self addSubview:_noConnectionLabel];
        [self addSubview:_retryButton];
    }
    return self;
}


- (void)setNoConnectionImage:(UIImage *)img {
    _noConnectionView.image = img;
    _noConnectionView.frame = CGRectMake((self.frame.size.width - img.size.width) / 2.0f,
                                         (self.frame.size.height - img.size.height) / 2.0f - 100.0f,
                                         img.size.width,
                                         img.size.height);
}


- (void)setNoConnectionText:(NSString *)text {
    _noConnectionLabel.text = text;
}

- (void)tryAgain {
    _retryButton.enabled = NO;
    [delegate tryConnectionAgain];
}

@end
