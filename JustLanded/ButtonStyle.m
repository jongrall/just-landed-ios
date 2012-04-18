//
//  ButtonStyle.m
//  JustLanded
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "ButtonStyle.h"

@interface ButtonStyle () {
    __strong LabelStyle *_labelStyle;
    __strong UIColor *_backgroundColor;
    __strong UIImage *_upImage;
    __strong UIImage *_downImage;
    __strong UIImage *_disabledImage;
    __strong UIImage *_iconImage;
    CGPoint _iconOrigin;
    UIEdgeInsets _labelInsets;
    CGSize _downLabelOffset;
    CGSize _disabledLabelOffset;
}

@end

@implementation ButtonStyle

@synthesize labelStyle=_labelStyle;
@synthesize backgroundColor=_backgroundColor;
@synthesize upImage=_upImage;
@synthesize downImage=_downImage;
@synthesize disabledImage=_disabledImage;
@synthesize icon=_iconImage;
@synthesize iconOrigin=_iconOrigin;
@synthesize labelInsets=_labelInsets;
@synthesize downLabelOffset=_downLabelOffset;
@synthesize disabledLabelOffset=_disabledLabelOffset;


- (id)initWithLabelStyle:(LabelStyle *)aStyle
         backgroundColor:(UIColor *)aColor
                 upImage:(UIImage *)anUpImage
               downImage:(UIImage *)aDownImage
           disabledImage:(UIImage *)aDisabledImage
               iconImage:(UIImage *)anIcon
              iconOrigin:(CGPoint)somePoint
             labelInsets:(UIEdgeInsets)someLabelInsets
         downLabelOffset:(CGSize)aDownOffset
     disabledLabelOffset:(CGSize)aDisabledOffset {    
    self = [super init];
    
    if (self) {
        _labelStyle = aStyle;
        
        if (aColor != nil) {
            _backgroundColor = aColor;
        }
        else {
            _backgroundColor = [UIColor clearColor];
        }
        
        _upImage = anUpImage;
        _downImage = aDownImage;
        _disabledImage = aDisabledImage;
        _iconImage = anIcon;
        _iconOrigin = somePoint;
        _labelInsets = someLabelInsets;
        _downLabelOffset = aDownOffset;
        _disabledLabelOffset = aDisabledOffset;
    }
    
    return self;
}

@end
