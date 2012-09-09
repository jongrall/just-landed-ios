//
//  JLMultipartLabel.h
//  Just Landed
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLabel.h"

@interface JLMultipartLabel : UIView

@property (copy, nonatomic) NSArray *parts;
@property (copy, nonatomic) NSArray *styles;
@property (copy, nonatomic) NSArray *offsets;

- (id)initWithLabelStyles:(NSArray *)styles frame:(CGRect)aFrame;

@end
