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

CGRect const TABLE_FRAME = {7.0f, 8.0f, 306.0f, 330.0f};
CGRect const COMPANY_NAME_FRAME = {20.0f, 347.0f, 280.0f, 20.0f};
CGRect const VERSION_FRAME = {20.0f, 385.0f, 280.0f, 20.0f};
CGRect const DIVIDER_FRAME = {35.0f, 372.0f, 250.0f, 1.0f};

@implementation JLAboutStyles

static LabelStyle *_companyLabelStyle;
static LabelStyle *_versionLabelStyle;

+ (LabelStyle *)companyLabelStyle {
    if (!_companyLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightBoldOfSize:14.0f]
                                                         color:[UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:1.0f];
        
        _companyLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                   backgroundColor:nil  
                                                         alignment:UITextAlignmentCenter 
                                                     lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    return _companyLabelStyle;
}


+ (LabelStyle *)versionLabelStyle {
    if (!_versionLabelStyle) {
        TextStyle *textStyle = [[TextStyle alloc] initWithFont:[JLStyles sansSerifLightOfSize:14.0f]
                                                         color:[UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f]
                                                   shadowColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.8f]
                                                  shadowOffset:CGSizeMake(0.0f, 1.0f) 
                                                    shadowBlur:1.0f];
        
        _versionLabelStyle = [[LabelStyle alloc] initWithTextStyle:textStyle
                                                   backgroundColor:nil 
                                                         alignment:UITextAlignmentCenter 
                                                     lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    return _versionLabelStyle;
}

@end
