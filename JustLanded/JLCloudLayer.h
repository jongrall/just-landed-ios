//
//  JLCloudLayer.h
//  Just Landed
//
//  Created by Jon Grall on 4/23/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;

@interface JLCloudLayer : UIView

- (void)startAnimating;
- (void)stopAnimating;

@property (copy, nonatomic) NSArray *currentCloudOffsets;

@end
