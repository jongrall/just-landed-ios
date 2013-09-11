//
//  JLAboutStyles.h
//  Just Landed
//
//  Created by Jon Grall on 5/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import Foundation;
#import "LabelStyle.h"
#import "ButtonStyle.h"

extern NSTimeInterval const CLOUD_REVEAL_ANIMATION_DURATION;
extern NSTimeInterval const FADE_ANIMATION_DURATION;

@interface JLAboutStyles : NSObject

+ (CGRect)aboutTitleFrame;
+ (CGRect)tableFrame;
+ (CGRect)copyrightNoticeFrame;
+ (CGRect)cloudLayerLowerFrame;
+ (CGRect)cloudFooterLowerFrame;
+ (CGRect)airplaneLowerFrame;
+ (LabelStyle *)aboutTitleLabelStyle;
+ (LabelStyle *)copyrightLabelStyle;
+ (ButtonStyle *)aboutCloseButtonStyle;

@end
