//
//  NSNotificationCenter+JLExtensions.h
//  JustLanded
//
//  Created by Jon Grall on 6/22/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (JLExtensions)

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject;
- (void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
