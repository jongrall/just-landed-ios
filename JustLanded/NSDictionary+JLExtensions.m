//
//  NSDictionary+JLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "NSDictionary+JLExtensions.h"


@implementation NSDictionary (JLExtensions)

- (id)objectForKeyOrNil:(id)key {
	id obj = [self objectForKey:key];
	
	//If the object being retrieved is an NSNull, just return nil
	if ([obj isKindOfClass:[NSNull class]]) {
		return nil;
	}
	
	return obj;
}


- (id)valueForKeyOrNil:(NSString *)key {
	id obj = [self valueForKey:key];
	
	//If the object being retrieved is an NSNull, just return nil
	if ([obj isKindOfClass:[NSNull class]]) {
		return nil;
	}
	
	return obj;
}


- (id)valueForKeyPathOrNil:(NSString *)keyPath {
	id obj = [self valueForKeyPath:keyPath];
	
	//If the object being retrieved is an NSNull, just return nil
	if ([obj isKindOfClass:[NSNull class]]) {
		return nil;
	}
	
	return obj;
}


@end