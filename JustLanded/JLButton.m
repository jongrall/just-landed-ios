//
//  JLButton.m
//  JustLanded
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLButton.h"

@interface JLButton () {
    __strong ButtonStyle *_style;
}

@end



@implementation JLButton

@synthesize labelText;
@synthesize style=_style;

- (id)initWithButtonStyle:(ButtonStyle *)aStyle frame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    
    if (self) {
        _style = aStyle;
        
        [self setBackgroundColor:[_style backgroundColor]];
        
        if ([_style upImage]) {
            [self setBackgroundImage:[_style upImage] forState:UIControlStateNormal];
        }
        
        if ([_style downImage]) {
            [self setBackgroundImage:[_style downImage] forState:UIControlStateHighlighted];
            [self setBackgroundImage:[_style downImage] forState:UIControlStateSelected];
        }
        
        if ([_style disabledImage]) {
            [self setBackgroundImage:[_style disabledImage] forState:UIControlStateDisabled];
        }
        
        if ([_style icon]) {
            [self setImage:[_style icon] forState:UIControlStateNormal];
        }
        
        
        LabelStyle *labelStyle = [_style labelStyle];
        
        if (labelStyle) {
            TextStyle *textStyle = [labelStyle textStyle];
            self.titleLabel.font = [textStyle font];
            self.titleLabel.textAlignment = [[_style labelStyle] alignment];
            
            if ([textStyle shadowColor]) {
                 [self setTitleShadowColor:[textStyle shadowColor] forState:UIControlStateNormal];
            }
            self.titleLabel.shadowOffset = [textStyle shadowOffset];
            [self setTitleColor:[textStyle color] forState:UIControlStateNormal];
        }
        
        //Stop images from highlighting
        self.adjustsImageWhenHighlighted = NO;
		
		//Don't adjust the image when disabled
		self.adjustsImageWhenDisabled = NO;
    }
    
    return self;
}


- (void)setEnabled:(BOOL)isEnabled {
    LabelStyle *labelStyle = [_style labelStyle];
    
    if (labelStyle) {
        TextStyle *textStyle = [labelStyle textStyle];
        
        // Reverse the shadow direction when disabled
        if ([textStyle shadowColor]) {
            CGSize offset = [textStyle shadowOffset];
            
            if (isEnabled) {
                self.titleLabel.shadowOffset = CGSizeMake(offset.width, -offset.height);
            }
            else {
                self.titleLabel.shadowOffset = offset;
            }
        }
    }
    
	[super setEnabled:isEnabled];
}


- (CGRect)titleRectForContentRect:(CGRect)contentRect {
	//Handle title vertical movement when selected/highlighted relative to the content rect
    UIEdgeInsets labelInsets = [_style labelInsets];
    CGSize shadowOffset = [[[_style labelStyle] textStyle] shadowOffset];
    CGSize shadowSize = CGSizeMake(abs(shadowOffset.width), abs(shadowOffset.height));
    
	switch (self.state) {
        case UIControlStateSelected:
		case UIControlStateHighlighted: {
            CGSize downOffset = [_style downLabelOffset];
            return CGRectMake(contentRect.origin.x + labelInsets.left + downOffset.width, 
                              contentRect.origin.y + labelInsets.top + downOffset.height, 
                              contentRect.size.width - labelInsets.left - labelInsets.right + shadowSize.width, 
                              contentRect.size.height - labelInsets.top - labelInsets.bottom + shadowSize.height);
            break;
        }
		case UIControlStateDisabled: {
            CGSize disabledOffset = [_style disabledLabelOffset];
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
    CGPoint iconOrigin = [_style iconOrigin];
    
    if ([self imageForState:UIControlStateNormal]) { // If it has an image
        CGSize imageSize = [self imageForState:UIControlStateNormal].size;
        
        switch (self.state) {
            case UIControlStateSelected:
            case UIControlStateHighlighted: {
                CGSize downOffset = [_style downLabelOffset];
                return CGRectMake(iconOrigin.x + downOffset.width, 
                                  iconOrigin.y + downOffset.height, 
                                  imageSize.width, 
                                  imageSize.height);
                break;
            }
            case UIControlStateDisabled: {
                CGSize disabledOffset = [_style disabledLabelOffset];
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
