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
        CGFloat errorDescriptionLabelOriginY = [UIScreen isMainScreenWide] ? 361.0f : 321.0f;
        errorDescriptionLabel_ = [[JLLabel alloc] initWithLabelStyle:[JLStyles errorDescriptionLabelStyle]
                                                               frame:CGRectMake(10.0f,
                                                                                errorDescriptionLabelOriginY,
                                                                                aFrame.size.width - 20.0f,
                                                                                50.0f)];
        
        CGFloat moreInfoButtonOriginY = [UIScreen isMainScreenWide] ? 401.0f : 313.0f;
        moreInfoButton_ = [[JLButton alloc] initWithButtonStyle:[JLStyles defaultButtonStyle]
                                                          frame:CGRectMake(10.0f,
                                                                           moreInfoButtonOriginY,
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
    CGFloat noConnectionLabelOriginY;
    CGFloat errorDescriptionLabelOriginY;
    CGFloat noConnectionImageViewOriginY;
    CGFloat dividerOriginY;
    
    
    switch (aType) {
        case ERROR_503: {
            self.noConnectionLabel.text = NSLocalizedString(@"Service Outage", @"Service Outage");
            self.errorDescriptionLabel_.text = NSLocalizedString(@"Just Landed is currently unavailable.", @"503 description");
            
            if ([UIScreen isMainScreenWide]) {
                noConnectionLabelOriginY = 274.0f;
                errorDescriptionLabelOriginY = 301.0f;
                noConnectionImageViewOriginY = 120.0f;
                dividerOriginY = 381.0f;
            }
            else {
                noConnectionLabelOriginY = 234.0f;
                errorDescriptionLabelOriginY = 261.0f;
                noConnectionImageViewOriginY = 80.0f;
                dividerOriginY = 293.0f;
            }

            [self addSubview:self.moreInfoButton_];
            
            break;
        }
        default: {
            self.noConnectionLabel.text = NSLocalizedString(@"Server Error", @"Server Error");
            self.errorDescriptionLabel_.text = NSLocalizedString(@"Our engineers have been notified.", @"500 description");
            
            if ([UIScreen isMainScreenWide]) {
                noConnectionLabelOriginY = 294.0f;
                errorDescriptionLabelOriginY = 321.0f;
                noConnectionImageViewOriginY = 140.0f;
                dividerOriginY = 441.0f;
            }
            else {
                noConnectionLabelOriginY = 254.0f;
                errorDescriptionLabelOriginY = 281.0f;
                noConnectionImageViewOriginY = 100.0f;
                dividerOriginY = 353.0f;
            }
            
            [self.moreInfoButton_ removeFromSuperview];
            
            break;
        }
    }
    
    self.noConnectionLabel.frame = CGRectMake((self.frame.size.width - 300.0f) / 2.0f,
                                              noConnectionLabelOriginY,
                                              300.0f,
                                              30.0f);
    
    self.errorDescriptionLabel_.frame = CGRectMake(10.0f,
                                                   errorDescriptionLabelOriginY,
                                                   self.frame.size.width - 20.0f,
                                                   50.0f);
    
    self.noConnectionImageView.image = [UIImage imageNamed:@"server_down"
                                                 withColor:nil
                                               shadowColor:[UIColor whiteColor]
                                              shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                shadowBlur:0.0f];
    
    self.noConnectionImageView.frame = CGRectMake((320.0f - self.noConnectionImageView.image.size.width) / 2.0f,
                                                  noConnectionImageViewOriginY,
                                                  self.noConnectionImageView.image.size.width,
                                                  self.noConnectionImageView.image.size.height);
    
    self.divider.frame = CGRectMake(self.divider.frame.origin.x,
                                    dividerOriginY,
                                    self.divider.frame.size.width,
                                    self.divider.frame.size.height);
}


- (void)moreInfo {
    [Flurry logEvent:FY_VISITED_OPS_FEED];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:NATIVE_TWITTER_JL_OPS]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NATIVE_TWITTER_JL_OPS]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_JL_OPS]];
    }
}

@end
