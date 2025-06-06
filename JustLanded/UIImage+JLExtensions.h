//
//  UIImage+JLExtensions.h
//  Just Landed
//
//  Created by Jon Grall on 4/20/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import UIKit;

@interface UIImage (JLExtensions)

+ (instancetype)imageNamed:(NSString *)name withColor:(UIColor *)color;
+ (instancetype)imageNamed:(NSString *)name withColor:(UIColor *)color shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowBlur:(CGFloat)blur;
+ (instancetype)imageNamed:(NSString *)name rotatedDegreesClockwise:(double)degrees shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowBlur:(CGFloat)blur;
- (UIImage *)croppedImage:(CGRect)bounds;

@end
