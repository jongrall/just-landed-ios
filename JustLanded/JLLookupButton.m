//
//  JLLookupButton.m
//  Just Landed
//
//  Created by Jon Grall on 4/15/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLookupButton.h"
#import "JLStyles.h"

@implementation JLLookupButton

@synthesize status = status_;

- (id)initWithButtonStyle:(ButtonStyle *)aStyle frame:(CGRect)aFrame status:(FlightStatus)aStatus {
    self = [super initWithButtonStyle:aStyle frame:aFrame];
    
    if (self) {
        [self setStatus:aStatus];
    }
    
    return self;
}


- (void)setStatus:(FlightStatus)newStatus {
    status_ = newStatus;
    NSString *upFileName = [NSString stringWithFormat:@"lookup_button_up_%@", [JLStyles colorNameForStatus:newStatus]];
    NSString *downFileName = [NSString stringWithFormat:@"lookup_button_down_%@", [JLStyles colorNameForStatus:newStatus]];
    UIColor *shadowColor = [JLStyles labelShadowColorForStatus:newStatus];
    
    [self setBackgroundImage:[[UIImage imageNamed:upFileName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)] forState:UIControlStateNormal];
    [self setBackgroundImage:[[UIImage imageNamed:downFileName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[[UIImage imageNamed:downFileName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)] forState:UIControlStateSelected];
    
    [self setImage:[UIImage imageNamed:@"lookup"
                             withColor:[UIColor whiteColor] 
                           shadowColor:[JLStyles labelShadowColorForStatus:newStatus]
                          shadowOffset:CGSizeMake(0.0f, -1.0f)
                            shadowBlur:0.0f]
          forState:UIControlStateNormal];
    
    [self setImage:[UIImage imageNamed:@"lookup" withColor:shadowColor]
          forState:UIControlStateDisabled];
    
    [self setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [self.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
    [self setTitleColor:shadowColor forState:UIControlStateDisabled];
    [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateDisabled];
}

@end
