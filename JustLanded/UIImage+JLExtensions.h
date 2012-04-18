//
//  UIImage+SLExtensions.h
//  SimplyListed
//
//  Created by Jon Grall on 4/27/11.
//  Copyright 2011 Friendfer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (SLExtensions)

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)resizedImage:(CGSize)newSize 
	 interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode 
								  bounds:(CGSize)bounds 
					interpolationQuality:(CGInterpolationQuality)quality;

@end