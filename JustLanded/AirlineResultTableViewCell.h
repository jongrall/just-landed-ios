//
//  AirlineResultTableViewCell.h
//  JustLanded
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import "ABTableViewCell.h"

@interface AirlineResultTableViewCell : ABTableViewCell

extern CGFloat const AirlineResultCellHeight;

@property (nonatomic, copy) NSString *airlineName;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *clearText;
@property (nonatomic) BOOL clearCell;

@end
