//
//  JLServerErrorView.m
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLServerErrorView.h"
#import "JLStyles.h"

@interface JLServerErrorView ()

@property (strong, nonatomic) JLLabel *errorDescriptionLabel_;
@property (strong, nonatomic) JLButton *moreInfoButton_;

- (void)moreInfo;

@end


@implementation JLServerErrorView

@synthesize errorType = errorType_;
@synthesize errorDescriptionLabel_;
@synthesize moreInfoButton_;

- (id)initWithFrame:(CGRect)aFrame errorType:(ErrorType)type {
    self = [super initWithFrame:aFrame];
    if (self) {
        errorDescriptionLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLStyles errorDescriptionLabelStyle]
                                                               frame:CGRectMake(10.0f,
                                                                                321.0f, // FIXME: iPhone 5 screen
                                                                                aFrame.size.width - 20.0f,
                                                                                50.0f)];
        
        moreInfoButton_ = [[JLButton alloc] initWithButtonStyle:[JLStyles defaultButtonStyle]
                                                          frame:CGRectMake(10.0f,
                                                                           313.0f, // FIXME: iPhone 5 screen
                                                                           aFrame.size.width - 20.0f,
                                                                           56.0f)];
        moreInfoButton_.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [moreInfoButton_ setTitle:NSLocalizedString(@"More Info", @"More Info") forState:UIControlStateNormal];
        [moreInfoButton_ addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
        
        [self setErrorType:type];
        [self addSubview:errorDescriptionLabel_];
    }
    return self;
}


- (NSString *)errorDescription {
    return self.errorDescriptionLabel_.text;
}


- (void)setErrorDescription:(NSString *)newDescription {
    self.errorDescriptionLabel_.text = newDescription;
}


- (void)setErrorType:(ErrorType)aType {
    errorType_ = aType;
    switch (aType) {
        case ERROR_503: {
            self.noConnectionLabel.text = NSLocalizedString(@"Service Outage", @"Service Outage");
            self.errorDescriptionLabel_.text = NSLocalizedString(@"Just Landed is currently unavailable.", @"503 description");
            
            self.noConnectionLabel.frame = CGRectMake((self.frame.size.width - 300.0f) / 2.0f,
                                                      234.0f, // FIXME: iPhone 5 screen
                                                      300.0f,
                                                      30.0f);
            
            self.errorDescriptionLabel_.frame = CGRectMake(10.0f,
                                                      261.0f, // FIXME: iPhone 5 screen
                                                      self.frame.size.width - 20.0f,
                                                      50.0f);
            
            self.noConnectionImageView.image = [UIImage imageNamed:@"server_down"
                                                         withColor:nil
                                                       shadowColor:[UIColor whiteColor] 
                                                      shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                        shadowBlur:0.0f];
            self.noConnectionImageView.frame = CGRectMake((320.0f - self.noConnectionImageView.image.size.width) / 2.0f,
                                                          80.0f, // FIXME: iPhone 5 screen
                                                          self.noConnectionImageView.image.size.width,
                                                          self.noConnectionImageView.image.size.height);
            self.divider.frame = CGRectMake(self.divider.frame.origin.x,
                                            293.0f, // FIXME: iPhone 5 screen
                                            self.divider.frame.size.width,
                                            self.divider.frame.size.height);
            
            [self addSubview:self.moreInfoButton_];
            
            break;
        }
        default: {
            self.noConnectionLabel.text = NSLocalizedString(@"Server Error", @"Server Error");
            self.errorDescriptionLabel_.text = NSLocalizedString(@"Our engineers have been notified.", @"500 description");
            
            self.noConnectionLabel.frame = CGRectMake((self.frame.size.width - 300.0f) / 2.0f,
                                                      294.0f, // FIXME: iPhone 5 screen
                                                      300.0f,
                                                      30.0f);
            
            self.errorDescriptionLabel_.frame = CGRectMake(10.0f,
                                                      321.0f, // FIXME: iPhone 5 screen
                                                      self.frame.size.width - 20.0f,
                                                      50.0f);
            
            self.noConnectionImageView.image = [UIImage imageNamed:@"server_down" 
                                                         withColor:nil
                                                       shadowColor:[UIColor whiteColor] 
                                                      shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                        shadowBlur:0.0f];
            self.noConnectionImageView.frame = CGRectMake((320.0f - self.noConnectionImageView.image.size.width) / 2.0f,
                                                          100.0f, // FIXME: iPhone 5 screen
                                                          self.noConnectionImageView.image.size.width,
                                                          self.noConnectionImageView.image.size.height);
            self.divider.frame = CGRectMake(self.divider.frame.origin.x,
                                            353.0f, // FIXME: iPhone 5 screen
                                            self.divider.frame.size.width,
                                            self.divider.frame.size.height);
            
            [self.moreInfoButton_ removeFromSuperview];
            
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
