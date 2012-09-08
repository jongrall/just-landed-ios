//
//  TextStyle.h
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextStyle : NSObject

@property (strong, readonly, nonatomic) UIFont *font;
@property (strong, readonly, nonatomic) UIColor *color;
@property (strong, readonly, nonatomic) UIColor *shadowColor;
@property (readonly, nonatomic) CGSize shadowOffset;
@property (readonly, nonatomic) CGFloat shadowBlur;

- (id)initWithFont:(UIFont *)font
             color:(UIColor *)color
       shadowColor:(UIColor *)color
      shadowOffset:(CGSize)offset
        shadowBlur:(CGFloat)blur;

@end
