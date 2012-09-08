//
//  ButtonStyle.m
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "ButtonStyle.h"

@interface ButtonStyle ()

// Redefine as readwrite
@property (strong, readwrite, nonatomic) LabelStyle *labelStyle;
@property (strong, readwrite, nonatomic) LabelStyle *disabledLabelStyle;
@property (strong, readwrite, nonatomic) UIColor *backgroundColor;
@property (strong, readwrite, nonatomic) UIImage *upImage;
@property (strong, readwrite, nonatomic) UIImage *downImage;
@property (strong, readwrite, nonatomic) UIImage *disabledImage;
@property (strong, readwrite, nonatomic) UIImage *icon;
@property (strong, readwrite, nonatomic) UIImage *disabledIcon;
@property (readwrite, nonatomic) CGPoint iconOrigin;
@property (readwrite, nonatomic) UIEdgeInsets labelInsets;
@property (readwrite, nonatomic) CGSize downLabelOffset;
@property (readwrite, nonatomic) CGSize disabledLabelOffset;

@end

@implementation ButtonStyle

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
     disabledLabelOffset:(CGSize)aDisabledOffset {    
    self = [super init];
    
    if (self) {
        self.labelStyle = aStyle;
        
        if (aColor != nil) {
            self.backgroundColor = aColor;
        }
        else {
            self.backgroundColor = [UIColor clearColor];
        }
        
        self.disabledLabelStyle = aDisabledStyle;
        self.upImage = anUpImage;
        self.downImage = aDownImage;
        self.disabledImage = aDisabledImage;
        self.icon = anIcon;
        self.disabledIcon = aDisabledIcon;
        self.iconOrigin = aPoint;
        self.labelInsets = someLabelInsets;
        self.downLabelOffset = aDownOffset;
        self.disabledLabelOffset = aDisabledOffset;
    }
    
    return self;
}

@end
