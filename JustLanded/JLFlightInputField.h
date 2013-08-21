//
//  JLFlightInputField.h
//  Just Landed
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FlightInputErrorState) {
    FlightInputNoError = 0,
    FlightInputError,
};


@interface JLFlightInputField : UITextField

@property (nonatomic) FlightInputErrorState errorState;

@end
