//
//  JLLoadingView.h
//  JustLanded
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLLoadingView : UIView

@property (copy, nonatomic) NSString *loadingText;

- (void)startLoading;
- (void)stopLoading;

@end
