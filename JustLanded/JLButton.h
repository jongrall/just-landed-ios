//
//  JLButton.h
//  Just Landed
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonStyle.h"

@interface JLButton : UIButton

// Note JLButton ignores shadow blur!
@property (strong, readonly, nonatomic) ButtonStyle *style;

- (id)initWithButtonStyle:(ButtonStyle *)aStyle frame:(CGRect)aFrame;

@end
