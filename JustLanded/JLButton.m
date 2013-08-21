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

@synthesize style = style_;

- (id)initWithButtonStyle:(ButtonStyle *)aStyle frame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    if (self) {
        style_ = aStyle;
        
        [self setBackgroundColor:style_.backgroundColor];
        
        if (style_.upImage) {
            [self setBackgroundImage:style_.upImage forState:UIControlStateNormal];
        }
        
        if (style_.downImage) {
            [self setBackgroundImage:style_.downImage forState:UIControlStateHighlighted];
            [self setBackgroundImage:style_.downImage forState:UIControlStateSelected];
        }
        
        if (style_.disabledImage) {
            [self setBackgroundImage:style_.disabledImage forState:UIControlStateDisabled];
        }
        
        if (style_.icon) {
            [self setImage:style_.icon forState:UIControlStateNormal];
        }
        
        if (style_.disabledIcon) {
            [self setImage:style_.disabledIcon forState:UIControlStateDisabled];
        }
        
        LabelStyle *labelStyle = style_.labelStyle;
        
        if (labelStyle) {
            TextStyle *textStyle = labelStyle.textStyle;
            self.titleLabel.font = textStyle.font;
            self.titleLabel.textAlignment = style_.labelStyle.alignment;
            self.titleLabel.shadowOffset = textStyle.shadowOffset;
            [self setTitleColor:textStyle.color forState:UIControlStateNormal];
            [self setTitleShadowColor:textStyle.shadowColor forState:UIControlStateNormal];
        }
        
        LabelStyle *disabledStyle = style_.disabledLabelStyle;
        
        if (disabledStyle) {
            TextStyle *textStyle = disabledStyle.textStyle;
            self.titleLabel.font = textStyle.font;
            self.titleLabel.textAlignment = style_.labelStyle.alignment;
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
    CGSize shadowSize = CGSizeMake(fabsf(shadowOffset.width), fabsf(shadowOffset.height));
    
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
