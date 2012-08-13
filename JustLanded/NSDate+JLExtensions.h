//
//  NSDate+JLExtensions.h
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (JLExtensions)

+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp;
+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp returnNilForZero:(BOOL)flag;
+ (NSString *)naturalDateStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz;
+ (NSString *)naturalDayStringFromDate:(NSDate *)date;
+ (NSString *)naturalTimeStringFromDate:(NSDate *)date;
+ (NSString *)prettyPrintTimeDifference:(NSDate *)date;
+ (NSString *)timeIntervalToShortUnitString:(NSTimeInterval)interval leadingZeros:(BOOL)zeros;

@end;