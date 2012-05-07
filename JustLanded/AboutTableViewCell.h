//
//  AboutTableViewCell.h
//  JustLanded
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

typedef enum {
    TOP = 0,
    MIDDLE,
    BOTTOM,
} AboutCellType;

extern CGFloat const AboutTableViewCellWidth;
extern CGFloat const AboutTableViewCellHeight;

@interface AboutTableViewCell : ABTableViewCell

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *icon;
@property (nonatomic) AboutCellType cellType;
@property (nonatomic) BOOL hasDisclosureArrow;

@end
