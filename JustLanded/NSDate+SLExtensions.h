//
//  NSDate+SLExtensions.h
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//

#import <Foundation/Foundation.h>


@interface NSDate (SLExtensions)

+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp;
+ (NSString *)naturalDateStringFromDate:(NSDate *)date;

@end;