//
//  JLServerErrorView.h
//  JustLanded
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLNoConnectionView.h"

typedef enum {
    ERROR_500 = 0,
    ERROR_503,
} ErrorType;


@interface JLServerErrorView : JLNoConnectionView

- (id)initWithFrame:(CGRect)frame errorType:(ErrorType)type;

@property (copy, nonatomic) NSString *errorDescription;
@property (nonatomic) ErrorType errorType;

@end
