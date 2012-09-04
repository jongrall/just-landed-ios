//
//  JLFlightInputField.h
//  Just Landed
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FlightInputNoError = 0,
    FlightInputError,
} FlightInputErrorState;


@interface JLFlightInputField : UITextField

@property (nonatomic) FlightInputErrorState errorState;

@end
