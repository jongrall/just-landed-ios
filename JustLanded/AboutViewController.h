//
//  AboutViewController.h
//  Just Landed
//
//  Created by Jon Grall on 3/20/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;
#import "JLViewController.h"

@interface AboutViewController : JLViewController

@property (strong, nonatomic) JLCloudLayer *cloudLayer;
@property (strong, nonatomic) JLAirplaneView *airplane;

- (void)revealContent;

@end
