//
//  AboutTableViewCell.h
//  Just Landed
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;
#import "ABTableViewCell.h"

typedef NS_ENUM(NSUInteger, AboutCellType) {
    TOP = 0,
    MIDDLE,
    BOTTOM,
};

extern CGFloat const AboutTableViewCellWidth;
extern CGFloat const AboutTableViewCellHeight;

@interface AboutTableViewCell : ABTableViewCell

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) UIImage *downIcon;
@property (nonatomic) AboutCellType cellType;
@property (nonatomic) BOOL hasDisclosureArrow;

@end
