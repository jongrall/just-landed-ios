//
//  TextStyle.h
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextStyle : NSObject

@property (nonatomic, readonly) UIFont *font;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) UIColor *shadowColor;
@property (nonatomic, readonly) CGSize shadowOffset;
@property (nonatomic, readonly) CGFloat shadowBlur;

- (id)initWithFont:(UIFont *)font
             color:(UIColor *)color
       shadowColor:(UIColor *)color
      shadowOffset:(CGSize)offset
        shadowBlur:(CGFloat)blur;

@end
