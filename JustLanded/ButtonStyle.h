//
//  ButtonStyle.h
//  JustLanded
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelStyle.h"

@interface ButtonStyle : NSObject

@property (nonatomic, readonly) LabelStyle *labelStyle;
@property (nonatomic, readonly) LabelStyle *disabledLabelStyle;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIImage *upImage;
@property (nonatomic, readonly) UIImage *downImage;
@property (nonatomic, readonly) UIImage *disabledImage;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) UIImage *disabledIcon;
@property (nonatomic, readonly) CGPoint iconOrigin;
@property (nonatomic, readonly) UIEdgeInsets labelInsets;
@property (nonatomic, readonly) CGSize downLabelOffset;
@property (nonatomic, readonly) CGSize disabledLabelOffset;

- (id)initWithLabelStyle:(LabelStyle *)aStyle
      disabledLabelStyle:(LabelStyle *)aDisabledStyle
         backgroundColor:(UIColor *)aColor
                 upImage:(UIImage *)anUpImage
               downImage:(UIImage *)aDownImage
           disabledImage:(UIImage *)aDisabledImage
               iconImage:(UIImage *)anIcon
       iconDisabledImage:(UIImage *)aDisabledIcon
              iconOrigin:(CGPoint)aPoint
             labelInsets:(UIEdgeInsets)someLabelInsets
         downLabelOffset:(CGSize)aDownOffset
     disabledLabelOffset:(CGSize)aDisabledOffset;

@end
