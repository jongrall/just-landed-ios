//
//  JLLookupStyles.h
//  Just Landed
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelStyle.h"
#import "ButtonStyle.h"

@interface JLLookupStyles : NSObject

+ (CGRect)logoFrame;
+ (CGRect)lookupButtonFrame;
+ (CGRect)airportCodesLabelFrame;
+ (CGRect)airportCodesButtonFrame;
+ (CGRect)airlineNoResultsLabelFrame;
+ (CGRect)aboutButtonFrame;
+ (CGRect)lookupInputFrame;
+ (CGRect)lookupTextFieldFrame;
+ (CGRect)lookupLabelFrame;
+ (CGPoint)lookupSeparatorOrigin;
+ (CGRect)lookupLabelTextFrame;
+ (CGRect)lookupFieldFrame;
+ (CGRect)lookupSpinnerFrame;
+ (CGRect)cloudLayerFrame;
+ (CGRect)cloudFooterFrame;
+ (CGRect)airplaneFrame;
+ (CGRect)resultsTableFrame;
+ (CGRect)resultsTableContainerFrame;
+ (UIColor *)lookupFieldTintColor;
+ (ButtonStyle *)lookupButtonStyle;
+ (ButtonStyle *)aboutButtonStyle;
+ (ButtonStyle *)airportCodesButtonStyle;
+ (ButtonStyle *)airportCodesLabelButtonStyle;
+ (LabelStyle *)flightFieldLabelStyle;
+ (LabelStyle *)flightFieldErrorTextStyle;
+ (LabelStyle *)flightFieldTextStyle;
+ (LabelStyle *)noAirlineResultsLabel;

@end
