//
//  JLAboutStyles.h
//  Just Landed
//
//  Created by Jon Grall on 5/4/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabelStyle.h"

extern CGRect const TABLE_FRAME;
extern CGRect const COMPANY_NAME_FRAME;
extern CGRect const VERSION_FRAME;
extern CGRect const DIVIDER_FRAME;

@interface JLAboutStyles : NSObject

+ (LabelStyle *)companyLabelStyle;
+ (LabelStyle *)versionLabelStyle;

@end
