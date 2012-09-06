//
//  JLAboutStyles.h
//  Just Landed
//
//  Created by Jon Grall on 5/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabelStyle.h"
#import "ButtonStyle.h"

extern CGRect const ABOUT_TITLE_FRAME;
extern CGRect const TABLE_FRAME;
extern CGRect const COPYRIGHT_NOTICE_FRAME;
extern CGRect const CLOUD_LAYER_LOWER_FRAME;
extern CGRect const AIRPLANE_LOWER_FRAME;
extern NSTimeInterval const CLOUD_REVEAL_ANIMATION_DURATION;
extern NSTimeInterval const FADE_ANIMATION_DURATION;

@interface JLAboutStyles : NSObject

+ (LabelStyle *)aboutTitleLabelStyle;
+ (LabelStyle *)copyrightLabelStyle;
+ (ButtonStyle *)aboutCloseButtonStyle;

@end
