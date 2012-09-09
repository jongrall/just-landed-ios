//
//  JLLoadingView.m
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLoadingView.h"
#import "JLStyles.h"

@interface JLLoadingView ()

@property (strong, nonatomic) JLSpinner *loadingSpinner_;
@property (strong, nonatomic) JLLabel *loadingLabel_;

@end


@implementation JLLoadingView

- (id)initWithFrame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay_screens_bg"]];
        bgView.frame = aFrame;
        
        // Add the label
        self.loadingLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLStyles loadingLabelStyle]
                                                           frame:CGRectMake(10.0f,
                                                                            294.0f,
                                                                            aFrame.size.width - 20.0f,
                                                                            30.0f)];
        self.loadingLabel_.text = NSLocalizedString(@"Loading...", @"Loading...");
        
        
        // Configure the loading spinner;
        self.loadingSpinner_ = [[JLSpinner alloc] initWithFrame:CGRectZero];
        self.loadingSpinner_.frame = CGRectMake((aFrame.size.width - self.loadingSpinner_.frame.size.width) / 2.0f,
                                                130.0f,
                                                self.loadingSpinner_.frame.size.width,
                                                self.loadingSpinner_.frame.size.height);
        
        [self addSubview:bgView];
        [self addSubview:self.loadingSpinner_];
        [self addSubview:self.loadingLabel_];
    }
    return self;
}


- (NSString *)loadingText {
    return self.loadingLabel_.text;
}


- (void)setLoadingText:(NSString *)text {
    self.loadingLabel_.text = [text copy];
}


- (void)startLoading {
    self.hidden = NO;
    [self.loadingSpinner_ startAnimating];
}


- (void)stopLoading {
    self.hidden = YES;
    [self.loadingSpinner_ stopAnimating];
}

@end
