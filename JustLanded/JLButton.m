//
//  JLButton.m
//  Just Landed
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLButton.h"

@interface JLButton ()

// Redefine as readwrite
@property (strong, readwrite, nonatomic) ButtonStyle *style;

@end



@implementation JLButton

- (id)initWithButtonStyle:(ButtonStyle *)aStyle frame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    if (self) {
        self.style = aStyle;
        
        [self setBackgroundColor:self.style.backgroundColor];
        
        if (self.style.upImage) {
            [self setBackgroundImage:self.style.upImage forState:UIControlStateNormal];
        }
        
        if (self.style.downImage) {
            [self setBackgroundImage:self.style.downImage forState:UIControlStateHighlighted];
            [self setBackgroundImage:self.style.downImage forState:UIControlStateSelected];
        }
        
        if (self.style.disabledImage) {
            [self setBackgroundImage:self.style.disabledImage forState:UIControlStateDisabled];
        }
        
        if (self.style.icon) {
            [self setImage:self.style.icon forState:UIControlStateNormal];
        }
        
        if (self.style.disabledIcon) {
            [self setImage:self.style.disabledIcon forState:UIControlStateDisabled];
        }
        
        LabelStyle *labelStyle = self.style.labelStyle;
        
        if (labelStyle) {
            TextStyle *textStyle = labelStyle.textStyle;
            self.titleLabel.font = textStyle.font;
            self.titleLabel.textAlignment = self.style.labelStyle.alignment;
            self.titleLabel.shadowOffset = textStyle.shadowOffset;
            [self setTitleColor:textStyle.color forState:UIControlStateNormal];
            [self setTitleShadowColor:textStyle.shadowColor forState:UIControlStateNormal];
        }
        
        LabelStyle *disabledStyle = self.style.disabledLabelStyle;
        
        if (disabledStyle) {
            TextStyle *textStyle = disabledStyle.textStyle;
            self.titleLabel.font = textStyle.font;
            self.titleLabel.textAlignment = self.style.labelStyle.alignment;
            self.titleLabel.shadowOffset = textStyle.shadowOffset;
            [self setTitleColor:textStyle.color forState:UIControlStateDisabled];
            [self setTitleShadowColor:textStyle.shadowColor forState:UIControlStateDisabled];
        }
        
        //Stop images from highlighting
        self.adjustsImageWhenHighlighted = NO;
		
		//Don't adjust the image when disabled
		self.adjustsImageWhenDisabled = NO;
    }
    
    return self;
}


- (void)setEnabled:(BOOL)isEnabled {
    LabelStyle *labelStyle = self.style.labelStyle;
    
    if (labelStyle) {
        TextStyle *textStyle = labelStyle.textStyle;
        // Reverse the shadow direction when disabled
        CGSize offset = textStyle.shadowOffset;
            
        if (isEnabled) {
            self.titleLabel.shadowOffset = CGSizeMake(offset.width, -offset.height);
        }
        else {
            self.titleLabel.shadowOffset = offset;
        }
    }
    
	[super setEnabled:isEnabled];
}


- (CGRect)titleRectForContentRect:(CGRect)contentRect {
	//Handle title vertical movement when selected/highlighted relative to the content rect
    UIEdgeInsets labelInsets = self.style.labelInsets;
    CGSize shadowOffset = self.style.labelStyle.textStyle.shadowOffset;
    CGSize shadowSize = CGSizeMake(fabs(shadowOffset.width), fabs(shadowOffset.height));
    
	switch (self.state) {
        case UIControlStateSelected:
		case UIControlStateHighlighted: {
            CGSize downOffset = self.style.downLabelOffset;
            return CGRectMake(contentRect.origin.x + labelInsets.left + downOffset.width, 
                              contentRect.origin.y + labelInsets.top + downOffset.height, 
                              contentRect.size.width - labelInsets.left - labelInsets.right + shadowSize.width, 
                              contentRect.size.height - labelInsets.top - labelInsets.bottom + shadowSize.height);
            break;
        }
		case UIControlStateDisabled: {
            CGSize disabledOffset = self.style.disabledLabelOffset;
            return CGRectMake(contentRect.origin.x + labelInsets.left + disabledOffset.width, 
                              contentRect.origin.y + labelInsets.top + disabledOffset.height, 
                              contentRect.size.width - labelInsets.left - labelInsets.right + shadowSize.width, 
                              contentRect.size.height - labelInsets.top - labelInsets.bottom + shadowSize.height);
            break;
        }
		default: {
            return CGRectMake(contentRect.origin.x + labelInsets.left, 
                              contentRect.origin.y + labelInsets.top, 
                              contentRect.size.width - labelInsets.left - labelInsets.right + shadowSize.width, 
                              contentRect.size.height - labelInsets.top - labelInsets.bottom + shadowSize.height);
            break;
        }
	}
}


- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    //Handle icon vertical movement when selected/highlighted relative to the content rect
    CGPoint iconOrigin = self.style.iconOrigin;
    
    if ([self imageForState:UIControlStateNormal]) { // If it has an image
        CGSize imageSize = [self imageForState:UIControlStateNormal].size;
        
        switch (self.state) {
            case UIControlStateSelected:
            case UIControlStateHighlighted: {
                CGSize downOffset = self.style.downLabelOffset;
                return CGRectMake(iconOrigin.x + downOffset.width, 
                                  iconOrigin.y + downOffset.height, 
                                  imageSize.width, 
                                  imageSize.height);
                break;
            }
            case UIControlStateDisabled: {
                CGSize disabledOffset = self.style.disabledLabelOffset;
                return CGRectMake(iconOrigin.x + disabledOffset.width, 
                                  iconOrigin.y + disabledOffset.height, 
                                  imageSize.width, 
                                  imageSize.height);
                break;
            }
            default: {
                return CGRectMake(iconOrigin.x, 
                                  iconOrigin.y, 
                                  imageSize.width, 
                                  imageSize.height);
                break;
            }
        }
    }
    else {
        return CGRectZero;
    }
}


@end
