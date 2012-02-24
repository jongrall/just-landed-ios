//
//  NSDate+JLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//

#import "NSDate+JLExtensions.h"
#import <math.h>


@implementation NSDate (JLExtensions)

static NSDateFormatter *_naturalDateFormatter;

+ (void)initialize {
	if (self == [NSDate class]) {
		//Create a nice date formatter
		_naturalDateFormatter = [[NSDateFormatter alloc] init];
		[_naturalDateFormatter setCalendar:[NSCalendar autoupdatingCurrentCalendar]];
		[_naturalDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
		[_naturalDateFormatter setLocale:[NSLocale currentLocale]];
		[_naturalDateFormatter setDateFormat:@"E, MMM d 'at' h:mm a"];
	}
}

+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp {
    return [self dateWithTimestamp:timestamp returnNilForZero:NO];
}

+ (NSDate *)dateWithTimestamp:(NSNumber *)timestamp returnNilForZero:(BOOL)flag {
    if (timestamp && [timestamp isKindOfClass:[NSNumber class]]) {
        if (flag && [timestamp integerValue] == 0) {
            return nil;
        }
		return [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
	}
	else {
		return nil;
	}
}


+ (NSString *)naturalDateStringFromDate:(NSDate *)date {
	
	if (date) {
		NSDate *now = [NSDate date];
		
		//Calculations for "Today", "Yesterday" and "Tomorrow"
		NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
		NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit)
												   fromDate:now];
		
		NSDate *todayAtMidnight = [calendar dateFromComponents:components];
		BOOL yesterday = [todayAtMidnight timeIntervalSinceDate:date] > 0.0 && [todayAtMidnight timeIntervalSinceDate:date] <= 86400.0;
		BOOL today = [date timeIntervalSinceDate:todayAtMidnight] >= 0.0 && [date timeIntervalSinceDate:todayAtMidnight] < 86400.0;
		BOOL tomorrow = [date timeIntervalSinceDate:todayAtMidnight] >= 86400.0 && [date timeIntervalSinceDate:todayAtMidnight] < 172800.0;
		
		if (yesterday) {
			return [NSString stringWithFormat:NSLocalizedString(@"Yesterday at %@", @"Yesterday at 3:24pm"), 
					[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
		}
		else if (today) {
			return [NSString stringWithFormat:NSLocalizedString(@"Today at %@", @"Today at 3:24pm"), 
					[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
		}
		else if (tomorrow) {
			return [NSString stringWithFormat:NSLocalizedString(@"Tomorrow at %@", @"Tomorrow at 3:24pm"), 
					[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
		}
		else {
			return [_naturalDateFormatter stringFromDate:date];
		}
	}
	else {
		return NSLocalizedString(@"Unknown Date", @"Unknown Date");
	}
}


+ (NSString *)prettyPrintTimeDifference:(NSDate *)date {
    NSTimeInterval interval = abs((int) [date timeIntervalSinceNow]);
    
    NSTimeInterval secondsInMinute = 60.0;
    NSTimeInterval secondsInHour = 3600.0;
    NSTimeInterval secondsInDay = 86400.0;
    NSTimeInterval secondsInYear = 365.0 * secondsInDay;
    
    NSInteger years = floor(interval / secondsInYear) > 0 ? (int) floor(interval / secondsInYear) : 0;
    NSInteger days = floor(interval / secondsInDay) > 0 ? (int) floor(fmod(interval, secondsInYear) / secondsInDay) : 0;
    NSInteger hours = floor(interval / secondsInHour) > 0 ? (int) floor(fmod(interval, secondsInDay) / secondsInHour) : 0;
    NSInteger minutes = floor(interval / secondsInMinute) > 0 ? (int) floor(fmod(interval, secondsInHour) / secondsInMinute) : 0;
    NSInteger seconds = interval > 0 ? (int) floor(fmod(interval, secondsInMinute)) : 0;
    
    NSString *difference = @"";
    if (years > 0) {
        difference = [difference stringByAppendingString:(years > 1 ? [NSString stringWithFormat:@"%d years", years] : @"1 year")];
    };
    if (days > 0) {
        difference = [difference stringByAppendingString:(days > 1 ? [NSString stringWithFormat:@"%d days", years] : @"1 day")];
    };
    if (hours > 0) {
        difference = [difference stringByAppendingString:(hours > 1 ? [NSString stringWithFormat:@"%d hours", years] : @"1 hour")];
    };
    if (minutes > 0) {
        difference = [difference stringByAppendingString:(minutes > 1 ? [NSString stringWithFormat:@"%d minutes", years] : @"1 minute")];
    };
    if (seconds > 0 && [difference isEqualToString:@""]) {
        difference = [difference stringByAppendingString:(seconds > 1 ? [NSString stringWithFormat:@"%d seconds", years] : @"1 second")];
    };
    
    return [difference isEqualToString:@""] ? @"now" : difference;
}


@end