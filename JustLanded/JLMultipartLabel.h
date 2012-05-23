//
//  JLMultipartLabel.h
//  JustLanded
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLLabel.h"

@interface JLMultipartLabel : UIView

@property (nonatomic, strong) NSArray *parts;
@property (nonatomic, strong) NSArray *styles;
@property (nonatomic, strong) NSArray *offsets;

- (id)initWithLabelStyles:(NSArray *)styles frame:(CGRect)aFrame;

@end
