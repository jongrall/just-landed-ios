//
//  JLLookupStyles.h
//  Just Landed
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextStyle.h"
#import "LabelStyle.h"
#import "ButtonStyle.h"

extern CGRect const LOGO_FRAME;
extern CGRect const LOOKUP_BUTTON_FRAME;
extern CGRect const AIRPORT_CODES_LABEL_FRAME;
extern CGRect const AIRPORT_CODES_BUTTON_FRAME;
extern CGRect const AIRLINE_NO_RESULTS_LABEL_FRAME;
extern CGRect const ABOUT_BUTTON_FRAME;
extern CGRect const LOOKUP_INPUT_FRAME;
extern CGRect const LOOKUP_TEXTFIELD_FRAME;
extern CGRect const LOOKUP_LABEL_FRAME;
extern CGPoint const LOOKUP_SEPARATOR_ORIGIN;
extern CGRect const LOOKUP_LABEL_TEXT_FRAME;
extern CGRect const LOOKUP_FIELD_FRAME;
extern CGRect const CLOUD_LAYER_FRAME;
extern CGRect const CLOUD_FOOTER_FRAME;
extern CGRect const RESULTS_TABLE_FRAME;
extern CGRect const RESULTS_TABLE_CONTAINER_FRAME;

@interface JLLookupStyles : NSObject

+ (ButtonStyle *)lookupButtonStyle;
+ (ButtonStyle *)aboutButtonStyle;
+ (ButtonStyle *)airportCodesButtonStyle;
+ (ButtonStyle *)airportCodesLabelButtonStyle;
+ (LabelStyle *)flightFieldLabelStyle;
+ (LabelStyle *)flightFieldErrorTextStyle;
+ (LabelStyle *)flightFieldTextStyle;
+ (LabelStyle *)noAirlineResultsLabel;

@end
