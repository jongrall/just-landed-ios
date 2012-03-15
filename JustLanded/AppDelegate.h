//
//  AppDelegate.h
//  JustLanded
//
//  Created by Jon Grall on 2/3/12.
//  Copyright (c) 2012 Just Landed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWQuincyManager.h"

@class FlightLookupViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, BWQuincyManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FlightLookupViewController *mainViewController;

@end
