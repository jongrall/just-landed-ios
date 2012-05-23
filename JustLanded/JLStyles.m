//
//  JLStyles.m
//  JustLanded
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLStyles.h"

@implementation JLStyles

static TextStyle *_navbarTitleStyle;
static ButtonStyle *_navbarButtonStyle;
static ButtonStyle *_navbarBackButtonStyle;
static LabelStyle *_loadingLabelStyle;
static LabelStyle *_noConnectionLabelStyle;
static LabelStyle *_errorDescriptionLabelStyle;
static ButtonStyle *_defaultButtonStyle;


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


+ (UIFont *)sansSerifLightBoldOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"FrutigerCE-Bold" size:size];
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


+ (UIColor *)colorForStatus:(FlightStatus)status {
    switch (status) {
        case SCHEDULED:
            return [UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f];
            break;
        case ON_TIME:
            return [UIColor colorWithRed:12.0f/255.0f green:114.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
            break;
        case DELAYED:
            return [UIColor colorWithRed:163.0f/255.0f green:44.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
            break;
        case CANCELED:
            return [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
            break;
        case DIVERTED:
            return [UIColor colorWithRed:163.0f/255.0f green:44.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
            break;
        case LANDED:
            return [UIColor colorWithRed:41.0f/255.0f green:144.0f/255.0f blue:54.0f/255.0f alpha:1.0f];
            break;
        case EARLY:
            return [UIColor colorWithRed:12.0f/255.0f green:114.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
            break;
        default:
            return [UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f];
            break;
    }
}


+ (NSString *)statusTextForStatus:(FlightStatus)status {
    switch (status) {
        case SCHEDULED:
            return NSLocalizedString(@"SCHEDULED", @"SCHEDULED");
            break;
        case ON_TIME:
            return NSLocalizedString(@"ON TIME", @"ON TIME");
            break;
        case DELAYED:
            return NSLocalizedString(@"DELAYED", @"DELAYED");
            break;
        case CANCELED:
            return NSLocalizedString(@"CANCELED", @"CANCELED");
            break;
        case DIVERTED:
            return NSLocalizedString(@"DIVERTED", @"DIVERTED");
            break;
        case LANDED:
            return NSLocalizedString(@"LANDED", @"LANDED");
            break;
        case EARLY:
            return NSLocalizedString(@"EARLY", @"EARLY");
            break;
        default:
            return @"";
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


+ (TextStyle *)navbarTitleStyle {
    if (!_navbarTitleStyle) {
        _navbarTitleStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:22.0f] 
                                                      color:[UIColor whiteColor]
                                                shadowColor:[UIColor colorWithRed:183.0f/255.0f green:56.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
                                               shadowOffset:CGSizeMake(0.0f, -1.0f) 
                                                 shadowBlur:0.0f];
    }
    
    return _navbarTitleStyle;
}


+ (ButtonStyle *)navbarButtonStyle {
    if (!_navbarButtonStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:12.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor colorWithRed:183.0f/255.0f green:56.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
                                                  shadowOffset:CGSizeMake(0.0, -0.5f) 
                                                    shadowBlur:0.0f];
        
        TextStyle *disabledTextStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:12.0f]
                                                                 color:[UIColor colorWithRed:204.0f/255.0f green:64.0f/255.0f blue:2.0f/255.0f alpha:1.0f]
                                                           shadowColor:[UIColor colorWithRed:255.0f/255.0f green:156.0f/255.0f blue:71.0f/255.0f alpha:0.5f]
                                                          shadowOffset:CGSizeMake(0.0, 0.5f)
                                                            shadowBlur:0.0f];
        
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                       backgroundColor:nil 
                                                             alignment:UITextAlignmentCenter 
                                                         lineBreakMode:UILineBreakModeTailTruncation];
        
        LabelStyle *disabledLabelStyle = [[LabelStyle alloc] initWithTextStyle:disabledTextStyle 
                                                               backgroundColor:nil 
                                                                     alignment:UITextAlignmentCenter 
                                                                 lineBreakMode:UILineBreakModeTailTruncation];
        
        
        UIImage *upImage = [[UIImage imageNamed:@"nav_button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 7.0f, 0.0f, 7.0f)];
        UIImage *downImage = [[UIImage imageNamed:@"nav_button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 7.0f, 0.0f, 7.0f)];
        
        _navbarButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle 
                                                  disabledLabelStyle:disabledLabelStyle 
                                                     backgroundColor:nil 
                                                             upImage:upImage
                                                           downImage:downImage
                                                       disabledImage:downImage
                                                           iconImage:nil 
                                                   iconDisabledImage:nil 
                                                          iconOrigin:CGPointZero 
                                                         labelInsets:UIEdgeInsetsZero
                                                     downLabelOffset:CGSizeMake(0.0f, 1.0f) 
                                                 disabledLabelOffset:CGSizeMake(0.0f, 0.0f)];
    }
    
    return _navbarButtonStyle;
}


+ (ButtonStyle *)navbarBackButtonStyle {
    if (!_navbarBackButtonStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:12.0f]
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor colorWithRed:183.0f/255.0f green:56.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
                                                  shadowOffset:CGSizeMake(0.0, -0.5f)
                                                    shadowBlur:0.0f];
        
        TextStyle *disabledTextStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:12.0f]
                                                                 color:[UIColor colorWithRed:204.0f/255.0f green:64.0f/255.0f blue:2.0f/255.0f alpha:1.0f]
                                                           shadowColor:[UIColor colorWithRed:255.0f/255.0f green:156.0f/255.0f blue:71.0f/255.0f alpha:0.5f]
                                                          shadowOffset:CGSizeMake(0.0, 0.5f) 
                                                            shadowBlur:0.0f];
        
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle 
                                                       backgroundColor:nil 
                                                             alignment:UITextAlignmentCenter 
                                                         lineBreakMode:UILineBreakModeTailTruncation];
        
        LabelStyle *disabledLabelStyle = [[LabelStyle alloc] initWithTextStyle:disabledTextStyle 
                                                               backgroundColor:nil 
                                                                     alignment:UITextAlignmentCenter 
                                                                 lineBreakMode:UILineBreakModeTailTruncation];
        
        
        UIImage *upImage = [[UIImage imageNamed:@"nav_button_back_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 21.0f, 0.0f, 7.0f)];
        UIImage *downImage = [[UIImage imageNamed:@"nav_button_back_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 21.0f, 0.0f, 7.0f)];
        
        _navbarBackButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle 
                                                  disabledLabelStyle:disabledLabelStyle 
                                                     backgroundColor:nil 
                                                             upImage:upImage
                                                           downImage:downImage
                                                       disabledImage:downImage
                                                           iconImage:nil 
                                                   iconDisabledImage:nil 
                                                          iconOrigin:CGPointZero 
                                                         labelInsets:UIEdgeInsetsZero 
                                                     downLabelOffset:CGSizeMake(0.0f, 1.0f) 
                                                 disabledLabelOffset:CGSizeMake(0.0f, 0.0f)];
    }
    
    return _navbarBackButtonStyle;
}


+ (LabelStyle *)loadingLabelStyle  {
    if (!_loadingLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:23.0f] 
                                                         color:[UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _loadingLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:UITextAlignmentCenter
                                                        lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    return _loadingLabelStyle;
}


+ (LabelStyle *)noConnectionLabelStyle {
    if (!_noConnectionLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:23.0f] 
                                                         color:[UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _noConnectionLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:UITextAlignmentCenter
                                                        lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    return _noConnectionLabelStyle;
}


+ (LabelStyle *)errorDescriptionLabelStyle {
    if (!_errorDescriptionLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:13.0f] 
                                                         color:[UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _errorDescriptionLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:UITextAlignmentCenter
                                                        lineBreakMode:UILineBreakModeWordWrap];
    }
    
    return _errorDescriptionLabelStyle;
}


+ (ButtonStyle *)defaultButtonStyle {
    if (!_defaultButtonStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:24.0f] 
                                                         color:[UIColor whiteColor]
                                                   shadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                    shadowBlur:0.0f];
        
        LabelStyle *labelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                       backgroundColor:nil 
                                                             alignment:UITextAlignmentCenter 
                                                         lineBreakMode:UILineBreakModeClip];
        
        TextStyle *disabledTextStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:24.0f] 
                                                                 color:[UIColor colorWithRed:204.0f/255.0f green:64.0f/255.0f blue:2.0f/255.0f alpha:1.0f]
                                                           shadowColor:[UIColor colorWithRed:255.0f/255.0f green:156.0f/255.0f blue:71.0f/255.0f alpha:0.5f]
                                                          shadowOffset:CGSizeMake(0.0f, 1.0f)
                                                            shadowBlur:0.0f];
        
        LabelStyle *disabledLabelStyle = [[LabelStyle alloc] initWithTextStyle:disabledTextStyle
                                                               backgroundColor:nil 
                                                                     alignment:UITextAlignmentCenter 
                                                                 lineBreakMode:UILineBreakModeClip];
        
        _defaultButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:labelStyle
                                                  disabledLabelStyle:disabledLabelStyle
                                                     backgroundColor:nil
                                                             upImage:[[UIImage imageNamed:@"button_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)]
                                                           downImage:[[UIImage imageNamed:@"button_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)] 
                                                       disabledImage:[[UIImage imageNamed:@"button_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)]
                                                           iconImage:nil
                                                   iconDisabledImage:nil
                                                          iconOrigin:CGPointZero 
                                                         labelInsets:UIEdgeInsetsMake(-3.5f, 0.0f, 0.0f, 0.0f) 
                                                     downLabelOffset:CGSizeMake(0.0f, 5.0f) 
                                                 disabledLabelOffset:CGSizeMake(0.0f, 2.5f)];
    }
    
    return _defaultButtonStyle;
}

@end
