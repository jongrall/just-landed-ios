//
//  AboutTableViewCell.h
//  JustLanded
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

extern CGFloat const AboutTableViewCellWidth;
extern CGFloat const AboutTableViewCellHeight;

@interface AboutTableViewCell : ABTableViewCell

@property (copy, nonatomic) NSString *title;

@end
