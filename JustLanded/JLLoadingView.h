//
//  JLLoadingView.h
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;

@interface JLLoadingView : UIView

@property (copy, nonatomic) NSString *loadingText;

- (void)startLoading;
- (void)stopLoading;

@end
