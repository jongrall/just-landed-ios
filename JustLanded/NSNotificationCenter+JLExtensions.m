//
//  NSNotificationCenter+JLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 6/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "NSNotificationCenter+JLExtensions.h"

@implementation NSNotificationCenter (JLExtensions)

- (void)postNotificationOnMainThread:(NSNotification *)notification {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wselector"
	[self performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
    #pragma clang diagnostic pop
}


- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject {
	NSNotification *notification = [NSNotification notificationWithName:aName object:anObject];
	[self postNotificationOnMainThread:notification];
}


- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
	NSNotification *notification = [NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo];
	[self postNotificationOnMainThread:notification];
}

@end
