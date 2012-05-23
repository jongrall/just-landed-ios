//
//  JLLabel.h
//  JustLanded
//
//  Created by Jon Grall on 4/14/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelStyle.h"

@interface JLLabel : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, readonly) LabelStyle *style;

- (id)initWithLabelStyle:(LabelStyle *)aStyle frame:(CGRect)aFrame;

@end
