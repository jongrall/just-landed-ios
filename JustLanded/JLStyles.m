//
//  JLStyles.m
//  JustLanded
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "JLStyles.h"

@implementation JLStyles

+ (UIFont *)regularScriptOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"SignPainter-HouseScript" size:size];
}


+ (UIFont *)sansSerifLightOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"FrutigerCE-Light" size:size];
}


+ (UIFont *)sansSerifRomanOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"FrutigerCE-Roman" size:size];
}


+ (UIFont *)sansSerifLightCondensedOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"FrutigerLT-LightCn" size:size];
}


+ (UIFont *)sansSerifBoldCondensedOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"FrutigerLT-BoldCn" size:size];
}


+ (NSString *)colorNameForStatus:(FlightStatus)status {
    switch (status) {
        case SCHEDULED:
            return @"gray";
            break;
        case ON_TIME:
            return @"blue";
            break;
        case DELAYED:
            return @"red";
            break;
        case CANCELED:
            return @"black";
            break;
        case DIVERTED:
            return @"red";
            break;
        case LANDED:
            return @"green";
            break;
        case EARLY:
            return @"blue";
            break;
        default:
            return @"gray";
            break;
    }
}


+ (UIColor *)labelShadowColorForStatus:(FlightStatus)status {
    switch (status) {
        case SCHEDULED:
            return [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.8f];
            break;
        case ON_TIME:
            return [UIColor colorWithRed:5.0f/255.0f green:79.0f/255.0f blue:124.0f/255.0f alpha:0.8f];
            break;
        case DELAYED:
            return [UIColor colorWithRed:110.0f/255.0f green:8.0f/255.0f blue:8.0f/255.0f alpha:0.8f];
            break;
        case CANCELED:
            return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.8f];
            break;
        case DIVERTED:
            return [UIColor colorWithRed:110.0f/255.0f green:8.0f/255.0f blue:8.0f/255.0f alpha:0.8f];
            break;
        case LANDED:
            return [UIColor colorWithRed:17.0f/255.0f green:78.0f/255.0f blue:28.0f/255.0f alpha:0.8f];
            break;
        case EARLY:
            return [UIColor colorWithRed:5.0f/255.0f green:79.0f/255.0f blue:124.0f/255.0f alpha:0.8f];
            break;
        default:
            return [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.8f];
            break;
    }
}

@end
