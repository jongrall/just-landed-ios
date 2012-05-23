//
//  LabelStyle.h
//  JustLanded
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextStyle.h"

@interface LabelStyle : NSObject

@property (nonatomic, readonly) TextStyle *textStyle;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UITextAlignment alignment;
@property (nonatomic, readonly) UILineBreakMode lineBreakMode;

- (id)initWithTextStyle:(TextStyle *)style
        backgroundColor:(UIColor *)aColor
              alignment:(UITextAlignment)anAlignment
          lineBreakMode:(UILineBreakMode)aMode;

@end
