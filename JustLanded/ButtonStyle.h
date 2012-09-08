//
//  ButtonStyle.h
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelStyle.h"

@interface ButtonStyle : NSObject

@property (strong, readonly, nonatomic) LabelStyle *labelStyle;
@property (strong, readonly, nonatomic) LabelStyle *disabledLabelStyle;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIImage *upImage;
@property (strong, readonly, nonatomic) UIImage *downImage;
@property (strong, readonly, nonatomic) UIImage *disabledImage;
@property (strong, readonly, nonatomic) UIImage *icon;
@property (strong, readonly, nonatomic) UIImage *disabledIcon;
@property (readonly, nonatomic) CGPoint iconOrigin;
@property (readonly, nonatomic) UIEdgeInsets labelInsets;
@property (readonly, nonatomic) CGSize downLabelOffset;
@property (readonly, nonatomic) CGSize disabledLabelOffset;

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
