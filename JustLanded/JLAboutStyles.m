//
//  JLAboutStyles.m
//  Just Landed
//
//  Created by Jon Grall on 5/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLAboutStyles.h"
#import "TextStyle.h"
#import "JLStyles.h"

NSTimeInterval const CLOUD_REVEAL_ANIMATION_DURATION = 0.45;
NSTimeInterval const FADE_ANIMATION_DURATION = 0.15;

@implementation JLAboutStyles

+ (CGRect)aboutTitleFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{20.0f, 38.0f}, {280.0f, 70.0f}};
    }
    else {
        return (CGRect) {{20.0f, 18.0f}, {280.0f, 70.0f}};
    }
}


+ (CGRect)tableFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{7.0f, 87.0f}, {306.0f, 368.0f}};
    }
    else {
        return (CGRect) {{7.0f, 67.0f}, {306.0f, 300.0f}};
    }
}


+ (CGRect)copyrightNoticeFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{20.0f, 517.0f}, {280.0f, 20.0f}};
    }
    else {
        return (CGRect) {{20.0f, 429.0f}, {280.0f, 20.0f}};
    }
}


+ (CGRect)cloudLayerLowerFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 401.0f}, {320.0f, 125.0f}};
    }
    else {
        return (CGRect) {{0.0f, 313.0f}, {320.0f, 125.0f}};
    }
}


+ (CGRect)cloudFooterLowerFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 526.0f}, {320.0f, 22.0f}};
    }
    else {
        return (CGRect) {{0.0f, 438.0f}, {320.0f, 22.0f}};
    }
}


+ (CGRect)airplaneLowerFrame {
    if ([UIScreen isMainScreenWide]) {
        return (CGRect) {{0.0f, 375.0f}, {320.0f, 24.0f}};
    }
    else {
        return (CGRect) {{0.0f, 355.0f}, {320.0f, 24.0f}};
    }
}


+ (LabelStyle *)aboutTitleLabelStyle {
    static LabelStyle *sAboutTitleLabelStyle = nil;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles regularScriptOfSize:50.0f]
                                                         color:[UIColor colorWithRed:234.0f/255.0f green:241.0f/255.0f blue:246.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:16.0f/255.0f green:33.0f/255.0f blue:91.0f/255.0f alpha:0.33f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.5f)
                                                    shadowBlur:1.0f];
        
        sAboutTitleLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                      backgroundColor:nil
                                                            alignment:NSTextAlignmentCenter
                                                        lineBreakMode:NSLineBreakByTruncatingTail];
    });

    return sAboutTitleLabelStyle;
}


+ (LabelStyle *)copyrightLabelStyle {
    static LabelStyle *sCopyrightLabelStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:12.0f]
                                                         color:[UIColor colorWithRed:179.0f/255.0f green:195.0f/255.0f blue:206.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        sCopyrightLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                     backgroundColor:nil 
                                                           alignment:NSTextAlignmentCenter 
                                                       lineBreakMode:NSLineBreakByTruncatingTail];
    }); 
    
    return sCopyrightLabelStyle;
}


+ (ButtonStyle *)aboutCloseButtonStyle {
    static ButtonStyle *sAboutCloseButtonStyle;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        sAboutCloseButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil
                                                      disabledLabelStyle:nil
                                                         backgroundColor:nil
                                                                 upImage:[UIImage imageNamed:@"about_close_up"]
                                                               downImage:[UIImage imageNamed:@"about_close_down"]
                                                           disabledImage:nil
                                                                iconImage:nil
                                                       iconDisabledImage:nil
                                                              iconOrigin:CGPointZero
                                                             labelInsets:UIEdgeInsetsZero
                                                         downLabelOffset:CGSizeZero
                                                     disabledLabelOffset:CGSizeZero];
    });
    
    return sAboutCloseButtonStyle;
}

@end
