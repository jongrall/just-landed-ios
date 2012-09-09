//
//  AirlineResultTableViewCell.h
//  Just Landed
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "ABTableViewCell.h"

extern CGFloat const AirlineResultCellHeight;

@interface AirlineResultTableViewCell : ABTableViewCell

@property (copy, nonatomic) NSString *airlineName;
@property (copy, nonatomic) NSString *airlineCode;
@property (copy, nonatomic) NSString *clearText;
@property (nonatomic) BOOL clearCell;

@end
