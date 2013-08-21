//
//  NSDate+JLExtensions.h
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RelativeDateKind) {
    OTHER_DATE = 0,
    YESTERDAY,
    TODAY,
    TOMORROW,
};

@interface NSDate (JLExtensions)

+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp;
+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp returnNilForZero:(BOOL)flag;
+ (RelativeDateKind)currentDateRelativeToDate:(NSDate *)date withTimezone:(NSTimeZone *)tz;
+ (NSString *)sanitizeTimeZoneString:(NSString *)tzString;
+ (NSString *)naturalDateStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz;
+ (NSString *)naturalDayStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz;
+ (NSString *)naturalTimeStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz;
+ (NSString *)prettyPrintTimeDifference:(NSDate *)date;
+ (NSString *)timeIntervalToShortUnitString:(NSTimeInterval)interval leadingZeros:(BOOL)zeros;

@end
