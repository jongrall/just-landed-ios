//
//  JLLookupStyles.h
//  JustLanded
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextStyle.h"
#import "LabelStyle.h"
#import "ButtonStyle.h"

extern CGRect const LOGO_FRAME;
extern CGRect const LOOKUP_BUTTON_FRAME;
extern CGRect const ABOUT_BUTTON_FRAME;
extern CGRect const LOOKUP_INPUT_FRAME;
extern CGRect const LOOKUP_TEXTFIELD_FRAME;
extern CGRect const LOOKUP_LABEL_FRAME;
extern CGPoint const LOOKUP_SEPARATOR_ORIGIN;
extern CGRect const LOOKUP_LABEL_TEXT_FRAME;
extern CGRect const LOOKUP_FIELD_FRAME;
extern CGRect const CLOUD_LAYER_FRAME;
extern CGRect const CLOUD_FOOTER_FRAME;

@interface JLLookupStyles : NSObject

+ (ButtonStyle *)lookupButtonStyle;
+ (ButtonStyle *)aboutButtonStyle;
+ (LabelStyle *)flightFieldLabelStyle;
+ (LabelStyle *)flightFieldTextStyle;

@end
