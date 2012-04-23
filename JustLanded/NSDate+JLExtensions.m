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
static NSDateFormatter *_naturalDayFormatter;
static NSDateFormatter *_naturalTimeFormatter;

+ (void)initialize {
	if (self == [NSDate class]) {
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSTimeZone *timezone = [NSTimeZone localTimeZone];
        NSLocale *locale = [NSLocale currentLocale];
        
		//Create a nice date formatter
		_naturalDateFormatter = [[NSDateFormatter alloc] init];
		[_naturalDateFormatter setCalendar:calendar];
		[_naturalDateFormatter setTimeZone:timezone];
		[_naturalDateFormatter setLocale:locale];
		[_naturalDateFormatter setDateFormat:@"E, MMM d 'at' h:mm a"];
        
        _naturalDayFormatter = [[NSDateFormatter alloc] init];
        [_naturalDayFormatter setCalendar:calendar];
		[_naturalDayFormatter setTimeZone:timezone];
		[_naturalDayFormatter setLocale:locale];
		[_naturalDayFormatter setDateFormat:@"M/d"];
        
        _naturalTimeFormatter = [[NSDateFormatter alloc] init];
        [_naturalTimeFormatter setCalendar:calendar];
		[_naturalTimeFormatter setTimeZone:timezone];
		[_naturalTimeFormatter setLocale:locale];
		[_naturalTimeFormatter setDateFormat:@"h:mm a"];
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
			return [NSString stringWithFormat:NSLocalizedString(@"yesterday at %@", @"yesterday at 3:24pm"), 
					[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
		}
		else if (today) {
			return [NSString stringWithFormat:NSLocalizedString(@"today at %@", @"today at 3:24pm"), 
					[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
		}
		else if (tomorrow) {
			return [NSString stringWithFormat:NSLocalizedString(@"tomorrow at %@", @"tomorrow at 3:24pm"), 
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


+ (NSString *)naturalDayStringFromDate:(NSDate *)date {
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
			return NSLocalizedString(@"Yesterday", @"Yesterday");
		}
		else if (today) {
			return NSLocalizedString(@"Today", @"Today");
		}
		else if (tomorrow) {
            return NSLocalizedString(@"Tomorrow", @"Tomorrow");
		}
		else {
			return [_naturalDayFormatter stringFromDate:date];
		}
    }
    else {
        return @"";
    }
}


+ (NSString *)naturalTimeStringFromDate:(NSDate *)date {
    if (date) {
        return [_naturalTimeFormatter stringFromDate:date];
    }
    else {
        return @"";
    }
}


+ (NSString *)prettyPrintTimeDifference:(NSDate *)date {
    NSTimeInterval interval = fabs(roundf([date timeIntervalSinceNow]));
    
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
        difference = [difference stringByAppendingString:(years > 1 ? [NSString stringWithFormat:@"%d years ", years] : @"1 year ")];
    };
    if (days > 0) {
        difference = [difference stringByAppendingString:(days > 1 ? [NSString stringWithFormat:@"%d days ", days] : @"1 day ")];
    };
    if (hours > 0) {
        difference = [difference stringByAppendingString:(hours > 1 ? [NSString stringWithFormat:@"%d hours ", hours] : @"1 hour ")];
    };
    if (minutes > 0) {
        difference = [difference stringByAppendingString:(minutes > 1 ? [NSString stringWithFormat:@"%d minutes ", minutes] : @"1 minute ")];
    };
    if (seconds >= 0 && [difference isEqualToString:@""]) {
        difference = [difference stringByAppendingString:(seconds > 1 ? [NSString stringWithFormat:@"%d seconds ", seconds] : @"1 second ")];
    };
    
    return [difference isEqualToString:@""] ? @"now" : [difference stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


+ (NSString *)timeIntervalToShortUnitString:(NSTimeInterval)interval leadingZeros:(BOOL)zeros {
    interval = fabs(roundf(interval));
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
        difference = [difference stringByAppendingString:(years < 10 && zeros ? [NSString stringWithFormat:@"0%d YRS ", years] : 
                                                          years == 1 ? @"1 YR " : [NSString stringWithFormat:@"%d YRS ", years])];
    };
    if (days > 0) {
        difference = [difference stringByAppendingString:(days < 10 && zeros ? [NSString stringWithFormat:@"%d DAYS ", days] : 
                                                          days == 1 ? @"1 DAY " : [NSString stringWithFormat:@"%d DAYS ", days])];
    };
    if (hours > 0) {
        difference = [difference stringByAppendingString:(hours < 10 && zeros ? [NSString stringWithFormat:@"0%d HRS ", hours] : 
                                                          hours == 1 ? @"1 HR " : [NSString stringWithFormat:@"%d HRS ", hours])];
    };
    if (minutes > 0) {
        difference = [difference stringByAppendingString:(minutes < 10 && zeros ? [NSString stringWithFormat:@"0%d MIN ", minutes] : 
                                                          minutes == 1 ? @"1 MIN " : [NSString stringWithFormat:@"%d MIN ", minutes])];
    };
    if (seconds >= 0 && [difference isEqualToString:@""]) {
        difference = [difference stringByAppendingString:(seconds < 10 && zeros ? [NSString stringWithFormat:@"0%d SECS ", seconds] : 
                                                          seconds == 1 ? @"1 SEC " : [NSString stringWithFormat:@"%d SECS ", seconds])];
    };
    
    return [difference stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


@end