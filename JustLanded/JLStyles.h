//
//  JLStyles.h
//  Just Landed
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Flight.h"
#import "TextStyle.h"
#import "ButtonStyle.h"
#import "LabelStyle.h"

@interface JLStyles : NSObject

+ (UIFont *)regularScriptOfSize:(CGFloat)size;
+ (UIFont *)sansSerifLightOfSize:(CGFloat)size;
+ (UIFont *)sansSerifRomanOfSize:(CGFloat)size;
+ (UIFont *)sansSerifLightCondensedOfSize:(CGFloat)size;
+ (UIFont *)sansSerifBoldCondensedOfSize:(CGFloat)size;
+ (UIFont *)sansSerifLightBoldOfSize:(CGFloat)size;
+ (NSString *)colorNameForStatus:(FlightStatus)aStatus;
+ (UIColor *)colorForStatus:(FlightStatus)aStatus;
+ (NSString *)statusTextForStatus:(FlightStatus)aStatus;
+ (UIColor *)labelShadowColorForStatus:(FlightStatus)aStatus;
+ (TextStyle *)navbarTitleStyle;
+ (ButtonStyle *)navbarButtonStyle;
+ (ButtonStyle *)navbarBackButtonStyle;
+ (LabelStyle *)loadingLabelStyle;
+ (LabelStyle *)noConnectionLabelStyle;
+ (LabelStyle *)errorDescriptionLabelStyle;
+ (ButtonStyle *)defaultButtonStyle;
+ (UIColor *)justLandedOrange;

@end
