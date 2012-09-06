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

CGRect const ABOUT_TITLE_FRAME = {20.0f, 18.0f, 280.0f, 70.0f};
CGRect const TABLE_FRAME = {7.0f, 67.0f, 306.0f, 300.0f};
CGRect const COPYRIGHT_NOTICE_FRAME = {20.0f, 429.0f, 280.0f, 20.0f};
CGRect const CLOUD_LAYER_LOWER_FRAME = {0.0f, 313.0f, 320.0f, 125.0f};
CGRect const AIRPLANE_LOWER_FRAME = {0.0f, 355.0f, 320.0f, 24.0f};
NSTimeInterval const CLOUD_REVEAL_ANIMATION_DURATION = 0.45;
NSTimeInterval const FADE_ANIMATION_DURATION = 0.15;

@implementation JLAboutStyles

static LabelStyle *_aboutTitleLabelStyle;
static LabelStyle *_copyrightLabelStyle;
static ButtonStyle *_aboutCloseButtonStyle;

+ (LabelStyle *)aboutTitleLabelStyle {
    if (!_aboutTitleLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles regularScriptOfSize:50.0f]
                                                         color:[UIColor colorWithRed:234.0f/255.0f green:241.0f/255.0f blue:246.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:16.0f/255.0f green:33.0f/255.0f blue:91.0f/255.0f alpha:0.33f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.5f)
                                                    shadowBlur:1.0f];
        
        _aboutTitleLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                     backgroundColor:nil
                                                           alignment:UITextAlignmentCenter
                                                       lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    return _aboutTitleLabelStyle;
}

+ (LabelStyle *)copyrightLabelStyle {
    if (!_copyrightLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:12.0f]
                                                         color:[UIColor colorWithRed:179.0f/255.0f green:195.0f/255.0f blue:206.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:0.0f];
        
        _copyrightLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                   backgroundColor:nil 
                                                         alignment:UITextAlignmentCenter 
                                                     lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    return _copyrightLabelStyle;
}

+ (ButtonStyle *)aboutCloseButtonStyle {
    if (!_aboutCloseButtonStyle) {
        _aboutCloseButtonStyle = [[ButtonStyle alloc] initWithLabelStyle:nil
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
    }
    
    return _aboutCloseButtonStyle;
}

@end
