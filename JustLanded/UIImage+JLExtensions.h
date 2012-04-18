//
//  UIImage+JLExtensions.h
//  SimplyListed
//
//  Created by Jon Grall on 4/27/11.
//  Copyright 2011 Friendfer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (JLExtensions)

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset  shadowBlur:(CGFloat)blur;

- (UIImage *)croppedImage:(CGRect)bounds;

@end