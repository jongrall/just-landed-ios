//
//  NSDate+JLExtensions.h
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//

#import <Foundation/Foundation.h>


@interface NSDate (JLExtensions)

+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp;
+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp returnNilForZero:(BOOL)flag;
+ (NSString *)naturalDateStringFromDate:(NSDate *)date;
+ (NSString *)prettyPrintTimeDifference:(NSDate *)date;

@end;