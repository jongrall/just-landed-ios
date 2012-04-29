//
//  JLStyles.h
//  JustLanded
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Flight.h"

@interface JLStyles : NSObject

+ (UIFont *)regularScriptOfSize:(CGFloat)size;
+ (UIFont *)sansSerifLightOfSize:(CGFloat)size;
+ (UIFont *)sansSerifRomanOfSize:(CGFloat)size;
+ (UIFont *)sansSerifLightCondensedOfSize:(CGFloat)size;
+ (UIFont *)sansSerifBoldCondensedOfSize:(CGFloat)size;
+ (UIFont *)sansSerifLightBoldOfSize:(CGFloat)size;
+ (NSString *)colorNameForStatus:(FlightStatus)status;
+ (UIColor *)colorForStatus:(FlightStatus)status;
+ (NSString *)statusTextForStatus:(FlightStatus)status;
+ (UIColor *)labelShadowColorForStatus:(FlightStatus)status;

@end
