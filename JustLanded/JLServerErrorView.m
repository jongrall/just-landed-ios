//
//  JLServerErrorView.m
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLServerErrorView.h"
#import "JLStyles.h"

@interface JLServerErrorView () {
    __strong JLLabel *_errorDescriptionLabel;
}

@property (nonatomic, strong) JLButton *_moreInfoButton;

- (void)moreInfo;

@end


@implementation JLServerErrorView

@synthesize errorDescription;
@synthesize errorType;
@synthesize _moreInfoButton;

- (id)initWithFrame:(CGRect)frame errorType:(ErrorType)type {
    self = [super initWithFrame:frame];
    if (self) {
        _errorDescriptionLabel = [[JLLabel alloc] initWithLabelStyle:[JLStyles errorDescriptionLabelStyle] 
                                                               frame:CGRectMake(10.0f,
                                                                                321.0f,
                                                                                frame.size.width - 20.0f,
                                                                                50.0f)];
        
        _moreInfoButton = [[JLButton alloc] initWithButtonStyle:[JLStyles defaultButtonStyle]
                                                          frame:CGRectMake(10.0f,
                                                                           313.0f,
                                                                           frame.size.width - 20.0f,
                                                                           56.0f)];
        _moreInfoButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [_moreInfoButton setTitle:NSLocalizedString(@"More Info", @"More Info") forState:UIControlStateNormal];
        [_moreInfoButton addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
        
        [self setErrorType:type];
        [self addSubview:_errorDescriptionLabel];
    }
    return self;
}


- (void)setErrorDescription:(NSString *)desc {
    _errorDescriptionLabel.text = desc;
}


- (void)setErrorType:(ErrorType)type {
    switch (type) {
        case ERROR_503: {
            self.noConnectionLabel.text = NSLocalizedString(@"Service Outage", @"Service Outage");
            _errorDescriptionLabel.text = NSLocalizedString(@"Just Landed is currently unavailable.", @"503 description");
            
            self.noConnectionLabel.frame = CGRectMake((self.frame.size.width - 300.0f) / 2.0f,
                                                      234.0f,
                                                      300.0f,
                                                      30.0f);
            
            _errorDescriptionLabel.frame = CGRectMake(10.0f,
                                                      261.0f,
                                                      self.frame.size.width - 20.0f,
                                                      50.0f);
            
            self.noConnectionImageView.image = [UIImage imageNamed:@"server_down"
                                                         withColor:nil
                                                       shadowColor:[UIColor whiteColor] 
                                                      shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                        shadowBlur:0.0f];
            self.noConnectionImageView.frame = CGRectMake((320.0f - self.noConnectionImageView.image.size.width) / 2.0f,
                                                          80.0f,
                                                          self.noConnectionImageView.image.size.width,
                                                          self.noConnectionImageView.image.size.height);
            self.divider.frame = CGRectMake(self.divider.frame.origin.x,
                                            293.0f,
                                            self.divider.frame.size.width,
                                            self.divider.frame.size.height);
            
            [self addSubview:_moreInfoButton];
            
            break;
        }
        default: {
            self.noConnectionLabel.text = NSLocalizedString(@"Server Error", @"Server Error");
            _errorDescriptionLabel.text = NSLocalizedString(@"Our engineers have been notified.", @"500 description");
            
            self.noConnectionLabel.frame = CGRectMake((self.frame.size.width - 300.0f) / 2.0f,
                                                      294.0f,
                                                      300.0f,
                                                      30.0f);
            
            _errorDescriptionLabel.frame = CGRectMake(10.0f,
                                                      321.0f,
                                                      self.frame.size.width - 20.0f,
                                                      50.0f);
            
            self.noConnectionImageView.image = [UIImage imageNamed:@"server_down" 
                                                         withColor:nil
                                                       shadowColor:[UIColor whiteColor] 
                                                      shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                        shadowBlur:0.0f];
            self.noConnectionImageView.frame = CGRectMake((320.0f - self.noConnectionImageView.image.size.width) / 2.0f,
                                                          100.0f,
                                                          self.noConnectionImageView.image.size.width,
                                                          self.noConnectionImageView.image.size.height);
            self.divider.frame = CGRectMake(self.divider.frame.origin.x,
                                            353.0f,
                                            self.divider.frame.size.width,
                                            self.divider.frame.size.height);
            
            [_moreInfoButton removeFromSuperview];
            
            break;
        }
    }
}


- (void)moreInfo {
    [FlurryAnalytics logEvent:FY_VISITED_OPS_FEED];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:NATIVE_TWITTER_JL_OPS]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NATIVE_TWITTER_JL_OPS]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_JL_OPS]];
    }
}

@end
