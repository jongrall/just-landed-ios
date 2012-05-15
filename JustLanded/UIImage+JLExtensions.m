//
//  UIImage+JLExtensions.m
//  SimplyListed
//
//  Created by Jon Grall on 4/27/11.
//  Copyright 2011 Friendfer. All rights reserved.
//

#import "UIImage+JLExtensions.h"

@interface UIImage ()

- (UIImage *)resizedImage:(CGSize)newSize 
				transform:(CGAffineTransform)transform 
		   drawTransposed:(BOOL)transpose 
	 interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

@end



@implementation UIImage (JLExtensions)


+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
	if (name == nil) {
		return nil;
	}
    
    if (color == nil) {
        return [UIImage imageNamed:name];
    }
	
	// load the image
	UIImage *img = [UIImage imageNamed:name];
	
	// begin a new image context, to draw our colored image onto
	UIGraphicsBeginImageContextWithOptions(img.size, NO, 0.0f);
	
	// get a reference to that context we created
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// set the fill color
	[color setFill];
	
	// translate/flip the graphics context (for transforming from CG* coords to UI* coords
	CGContextTranslateCTM(context, 0.0f, img.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	// set the blend mode to color burn, and the original image
	CGContextSetBlendMode(context, kCGBlendModeMultiply);
	CGRect rect = CGRectMake(0.0f, 0.0f, img.size.width, img.size.height);
	
	// set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
	CGContextClipToMask(context, rect, img.CGImage);
	CGContextAddRect(context, rect);
	CGContextDrawPath(context,kCGPathFill);
	
	
	// generate a new UIImage from the graphics context we drew onto
	UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//return the color-burned image
	return coloredImg;
}


+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowBlur:(CGFloat)blur {
	// Create a colored version of the source image
    UIImage *coloredImage = [UIImage imageNamed:name withColor:color];
    
    // Draw the image with a shadow
    if (shadowColor && coloredImage) {
        // New image size to make room for shadow
        CGSize newImageSize = CGSizeMake(coloredImage.size.width + fabs(offset.width) + 2.0f * blur,
                                         coloredImage.size.height + fabs(offset.height) + 2.0f * blur);
        
        // Calculate new image origin in its larger container based on shadow offset and blur
        CGPoint imageOrigin = CGPointZero;
        
        // Shift image to make room for shadow
        if (offset.width > 0.0f) {
            imageOrigin.x = blur;
        }
        else {
            imageOrigin.x = -offset.width + blur;
        }
        
        if (offset.height > 0.0f) {
            imageOrigin.y = blur;
        }
        else {
            imageOrigin.y = -offset.height + blur;
        }
 
        // begin a new image context, to draw our colored image onto
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, 0.0f);
        
        // get a reference to that context we created
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Draw the image with a the (colored) shadow
        CGContextSetShadowWithColor(context, offset, blur, [shadowColor CGColor]);        
        [coloredImage drawInRect:CGRectMake(imageOrigin.x, imageOrigin.y, coloredImage.size.width, coloredImage.size.height)];
        
        // generate a new UIImage from the graphics context we drew onto
        UIImage *shadowedColoredImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return the shadowed colored image
        return shadowedColoredImg;
    }
    else {
        return nil;
    }
}


+ (UIImage *)imageNamed:(NSString *)name rotatedDegreesClockwise:(double)degrees shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowBlur:(CGFloat)blur {
    // Create a rotated version of the source image
    UIImage *srcImage = [UIImage imageNamed:name];
    CGSize size = srcImage.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat angleInRadians = degrees * M_PI / 180.0;
	
    CGContextTranslateCTM(ctx, srcImage.size.width/2.0f, srcImage.size.height/2.0f);
    CGContextRotateCTM(ctx, angleInRadians);
    CGContextTranslateCTM(ctx, -srcImage.size.width/2.0, -srcImage.size.height/2.0f);
    [srcImage drawAtPoint:CGPointZero];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    // Draw the rotated image with a not-rotated shadow
    if (shadowColor && rotatedImage) {
        // begin a new image context, to draw our colored image onto

        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        
        // get a reference to that context we created
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Draw the image with a the (colored) shadow
        CGContextSetShadowWithColor(context, offset, blur, [shadowColor CGColor]);        
        [rotatedImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        
        // generate a new UIImage from the graphics context we drew onto
        UIImage *shadowedRotatedImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return the shadowed rotated image
        return shadowedRotatedImg;
    }
    else {
        return nil;
    }
}


// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}


@end
