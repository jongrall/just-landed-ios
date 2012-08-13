//
//  JLLoadingView.m
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
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
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay_screens_bg"]];
        bgView.frame = frame;
        
        // Add the label
        _loadingLabel = [[JLLabel alloc] initWithLabelStyle:[JLStyles loadingLabelStyle] 
                                                      frame:CGRectMake(10.0f,
                                                                       294.0f,
                                                                       frame.size.width - 20.0f,
                                                                       30.0f)];
        _loadingLabel.text = NSLocalizedString(@"Loading...", @"Loading...");
        
        
        // Configure the loading spinner;
        _loadingSpinner = [[JLSpinner alloc] initWithFrame:CGRectZero];
        _loadingSpinner.frame = CGRectMake((frame.size.width - _loadingSpinner.frame.size.width) / 2.0f,
                                           130.0f,
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
