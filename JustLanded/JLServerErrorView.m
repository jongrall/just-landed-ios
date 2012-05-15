//
//  JLServerErrorView.m
//  JustLanded
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLServerErrorView.h"
#import "JLStyles.h"

@interface JLServerErrorView () {
    __strong JLLabel *_errorDescriptionLabel;
}

@end


@implementation JLServerErrorView

@synthesize errorDescription;
@synthesize errorType;

- (id)initWithFrame:(CGRect)frame errorType:(ErrorType)type {
    self = [super initWithFrame:frame];
    if (self) {
        _errorDescriptionLabel = [[JLLabel alloc] initWithLabelStyle:[JLStyles errorDescriptionLabelStyle] 
                                                               frame:CGRectMake(10.0f,
                                                                                321.0f,
                                                                                frame.size.width - 20.0f,
                                                                                50.0f)];
        
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
            self.noConnectionText = NSLocalizedString(@"Service Outage", @"Service Outage");
            _errorDescriptionLabel.text = NSLocalizedString(@"Just Landed is currently unavailable.", @"503 description");
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
            break;
        }
        default: {
            self.noConnectionText = NSLocalizedString(@"Server Error", @"Server Error");
            _errorDescriptionLabel.text = NSLocalizedString(@"Our engineers have been notified.", @"500 description");
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
            break;
        }
    }
}

@end
