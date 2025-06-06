//
//  JLServerErrorView.h
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;
#import "JLNoConnectionView.h"

typedef NS_ENUM(NSUInteger, ErrorType) {
    ERROR_500 = 0,
    ERROR_503,
};


@interface JLServerErrorView : JLNoConnectionView

- (id)initWithFrame:(CGRect)frame errorType:(ErrorType)type;

@property (copy, nonatomic) NSString *errorDescription;
@property (nonatomic) ErrorType errorType;

@end
