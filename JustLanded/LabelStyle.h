//
//  LabelStyle.h
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextStyle.h"

@interface LabelStyle : NSObject

@property (strong, readonly, nonatomic) TextStyle *textStyle;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (readonly, nonatomic) UITextAlignment alignment;
@property (readonly, nonatomic) UILineBreakMode lineBreakMode;

- (id)initWithTextStyle:(TextStyle *)style
        backgroundColor:(UIColor *)aColor
              alignment:(UITextAlignment)anAlignment
          lineBreakMode:(UILineBreakMode)aMode;

@end
