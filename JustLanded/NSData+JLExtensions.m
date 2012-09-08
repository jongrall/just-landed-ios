//
//  NSData+JLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 2/21/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "NSData+JLExtensions.h"


@implementation NSData (JLExtensions)


- (NSString*)hexString {
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	const unsigned char *dataBuffer = [self bytes];
	
	for (NSUInteger i = 0; i < [self length]; ++i) {
		[stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[ i ]];
	}
	
	return stringBuffer;
}


@end
