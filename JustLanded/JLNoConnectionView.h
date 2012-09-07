//
//  JLNoConnectionView.h
//  Just Landed
//
//  Created by Jon Grall on 5/8/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoConnectionDelegate
- (void)tryConnectionAgain;
@end


@interface JLNoConnectionView : UIView

@property (weak, nonatomic) id <NoConnectionDelegate> delegate;
@property (strong, nonatomic) UIImageView *noConnectionImageView;
@property (strong, nonatomic) UIImageView *divider;
@property (readonly, nonatomic) JLLabel *noConnectionLabel;
@property (readonly, nonatomic) JLButton *tryAgainbutton;

@end
