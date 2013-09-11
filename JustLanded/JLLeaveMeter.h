//
//  JLLeaveMeter.h
//  Just Landed
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;

@interface JLLeaveMeter : UIView

@property (nonatomic) NSTimeInterval timeRemaining;
@property (nonatomic) NSTimeInterval meterMaxTimeRemaining;
@property (nonatomic) BOOL showEmptyMeter;

@end
