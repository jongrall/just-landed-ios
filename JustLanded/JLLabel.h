//
//  JLLabel.h
//  Just Landed
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelStyle.h"

@interface JLLabel : UIView

@property (copy, nonatomic) NSString *text;
@property (strong, readonly, nonatomic) LabelStyle *style;

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame;

@end
