//
//  JLLoadingView.m
//  JustLanded
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLLoadingView.h"
#import "JLStyles.h"

@interface JLLoadingView () {
    __strong JLSpinner *_loadingSpinner;
    __strong JLLabel *_loadingLabel;
}

@end



@implementation JLLoadingView

@synthesize loadingText;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // TODO: Add the background
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracking_footer_bg"]];
        bgView.frame = frame;
        
        // Add the label
        _loadingLabel = [[JLLabel alloc] initWithLabelStyle:[JLStyles loadingLabelStyle] 
                                                      frame:CGRectMake(10.0f,
                                                                       (frame.size.height - 30.0f)/2.0f - 50.0f,
                                                                       frame.size.width - 20.0f,
                                                                       30.0f)];
        _loadingLabel.text = NSLocalizedString(@"Loading...", @"Loading...");
        
        
        // TODO: Configure the loading spinner;
        _loadingSpinner = [[JLSpinner alloc] initWithFrame:CGRectZero];
        _loadingSpinner.frame = CGRectMake((frame.size.width - _loadingSpinner.frame.size.width) / 2.0f,
                                           (frame.size.height - _loadingSpinner.frame.size.height) / 2.0f,
                                           _loadingSpinner.frame.size.width,
                                           _loadingSpinner.frame.size.height);
        
        [self addSubview:bgView];
        [self addSubview:_loadingSpinner];
        [self addSubview:_loadingLabel];
    }
    return self;
}


- (void)setLoadingText:(NSString *)text {
    _loadingLabel.text = text;
}


- (void)startLoading {
    self.hidden = NO;
    [_loadingSpinner startAnimating];
}


- (void)stopLoading {
    self.hidden = YES;
    [_loadingSpinner stopAnimating];
}

@end
