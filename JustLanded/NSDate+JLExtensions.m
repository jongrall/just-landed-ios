//
//  NSDate+JLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "NSDate+JLExtensions.h"
#import <math.h>


@implementation NSDate (JLExtensions)

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


+ (RelativeDateKind)currentDateRelativeToDate:(NSDate *)date withTimezone:(NSTimeZone *)tz {
    if (date) {
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        tz = tz ? tz : [NSTimeZone localTimeZone];
        [calendar setTimeZone:tz];
        [calendar setLocale:[NSLocale currentLocale]];
        NSDate *now = [NSDate date];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit)
												   fromDate:now];
		NSDate *todayAtMidnight = [calendar dateFromComponents:components];
        
        if ([todayAtMidnight timeIntervalSinceDate:date] > 0.0 && [todayAtMidnight timeIntervalSinceDate:date] <= 86400.0) {
            return YESTERDAY;
        }
        else if ([date timeIntervalSinceDate:todayAtMidnight] >= 0.0 && [date timeIntervalSinceDate:todayAtMidnight] < 86400.0) {
            return TODAY;
        }
        else if ([date timeIntervalSinceDate:todayAtMidnight] >= 86400.0 && [date timeIntervalSinceDate:todayAtMidnight] < 172800.0) {
            return TOMORROW;
        }
        else {
            return OTHER_DATE;
        }
    }
    else {
        return OTHER_DATE;
    }
}


+ (NSString *)naturalDateStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz {
	
	if (date) {
		NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        tz = tz ? tz : localTimeZone;
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        [calendar setTimeZone:tz];
        [calendar setLocale:[NSLocale currentLocale]];
        
		RelativeDateKind relativeKind = [NSDate currentDateRelativeToDate:date withTimezone:tz];
        NSString *timeString = nil;
        
        if (relativeKind == OTHER_DATE) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setCalendar:calendar];
            [formatter setTimeZone:tz];
            [formatter setLocale:calendar.locale];
            [formatter setDateFormat:@"EEE, MMMM d"];
			return [formatter stringFromDate:date];
        }
        else {
            // Only show timezone abbreviation if not the current timezone
            if ([tz isEqualToTimeZone:localTimeZone]) {
                timeString = [NSDateFormatter localizedStringFromDate:date
                                                            dateStyle:NSDateFormatterNoStyle
                                                            timeStyle:NSDateFormatterShortStyle];
            }
            else {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setCalendar:calendar];
                [formatter setTimeZone:calendar.timeZone];
                [formatter setLocale:calendar.locale];
                [formatter setDateFormat:@"h:mm a"];
                timeString = [formatter stringFromDate:date];
                // Ensure tz abbreviation not too long, tz for date not now
                NSUInteger maxAbbrevLen = 4;
                NSString *tzAbbrev = [tz abbreviationForDate:date];
                tzAbbrev = [tzAbbrev length] > maxAbbrevLen ? [tzAbbrev substringToIndex:maxAbbrevLen] : tzAbbrev;
                timeString = [timeString stringByAppendingFormat:@" %@", tzAbbrev];
            }
            
            switch (relativeKind) {
                case YESTERDAY: {
                    return [NSString stringWithFormat:NSLocalizedString(@"yesterday %@", @"yesterday at 3:24pm"), timeString];
                }
                case TODAY: {
                    return [NSString stringWithFormat:NSLocalizedString(@"today %@", @"today at 3:24pm"), timeString];
                }
                default: {
                    return [NSString stringWithFormat:NSLocalizedString(@"tomorrow %@", @"tomorrow at 3:24pm"), timeString];
                }
            }
        }
	}
	else {
		return NSLocalizedString(@"Unknown Date", @"Unknown Date");
	}
}


+ (NSString *)naturalDayStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz {
    if (date) {
        //Calculations for "Today", "Yesterday" and "Tomorrow"
		NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        NSLocale *currentLocale = [NSLocale currentLocale];
        tz = tz ? tz : localTimeZone;
        [calendar setTimeZone:tz];
		[calendar setLocale:currentLocale];
        
        RelativeDateKind relativeKind = [NSDate currentDateRelativeToDate:date withTimezone:tz];
        
        switch (relativeKind) {
            case YESTERDAY: {
                return NSLocalizedString(@"Yesterday", @"Yesterday");
            }
            case TODAY: {
                return NSLocalizedString(@"Today", @"Today");
            }
            case TOMORROW: {
                return NSLocalizedString(@"Tomorrow", @"Tomorrow");
            }
            default: {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setCalendar:calendar];
                [formatter setTimeZone:tz];
                [formatter setLocale:currentLocale];
                [formatter setDateFormat:@"M/d"];
                return [formatter stringFromDate:date];
            }
        }
    }
    else {
        return @"";
    }
}


+ (NSString *)naturalTimeStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz {
    if (date) {
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        NSLocale *currentLocale = [NSLocale currentLocale];
        tz = tz ? tz : localTimeZone;
        [calendar setTimeZone:tz];
		[calendar setLocale:currentLocale];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:calendar];
		[formatter setTimeZone:tz];
		[formatter setLocale:currentLocale];
		[formatter setDateFormat:@"h:mm a"];
        return [formatter stringFromDate:date];
    }
    else {
        return @"";
    }
}


+ (NSString *)prettyPrintTimeDifference:(NSDate *)date {    
    NSTimeInterval secondsInMinute = 60.0;
    NSTimeInterval secondsInHour = 3600.0;
    NSTimeInterval secondsInDay = 86400.0;
    NSTimeInterval secondsInYear = 365.0 * secondsInDay;
    
    // Ensure the interval is positive and rounded to whole seconds
    NSTimeInterval interval = fabs(roundf([date timeIntervalSinceNow]));
    
    // Round up to nearest minute so 10 sec left returns 1 min left not 0 min left
    interval = ceil(interval / secondsInMinute) * secondsInMinute;
    
    NSInteger years = floor(interval / secondsInYear) > 0 ? (int) floor(interval / secondsInYear) : 0;
    NSInteger days = floor(interval / secondsInDay) > 0 ? (int) floor(fmod(interval, secondsInYear) / secondsInDay) : 0;
    NSInteger hours = floor(interval / secondsInHour) > 0 ? (int) floor(fmod(interval, secondsInDay) / secondsInHour) : 0;
    NSInteger minutes = floor(interval / secondsInMinute) > 0 ? (int) floor(fmod(interval, secondsInHour) / secondsInMinute) : 0;
    
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
    if ([difference length] == 0) {
        difference = @"0 minutes ";
    }
    
    return [difference stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


+ (NSString *)timeIntervalToShortUnitString:(NSTimeInterval)anInterval leadingZeros:(BOOL)zeros {    
    NSTimeInterval secondsInMinute = 60.0;
    NSTimeInterval secondsInHour = 3600.0;
    NSTimeInterval secondsInDay = 86400.0;
    NSTimeInterval secondsInYear = 365.0 * secondsInDay;
    
    // Ensure the interval is positive and rounded to whole seconds
    NSTimeInterval interval = fabs(roundf(anInterval));
    // Round up to nearest minute so 10 sec left returns 1 min left not 0 min left
    interval = ceil(interval / secondsInMinute) * secondsInMinute;
    
    NSInteger years = floor(interval / secondsInYear) > 0 ? (int) floor(interval / secondsInYear) : 0;
    NSInteger days = floor(interval / secondsInDay) > 0 ? (int) floor(fmod(interval, secondsInYear) / secondsInDay) : 0;
    NSInteger hours = floor(interval / secondsInHour) > 0 ? (int) floor(fmod(interval, secondsInDay) / secondsInHour) : 0;
    NSInteger minutes = floor(interval / secondsInMinute) > 0 ? (int) floor(fmod(interval, secondsInHour) / secondsInMinute) : 0;
    
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
    }
    if ([difference length] == 0) {
        difference = (zeros) ? @"00 MIN " : @"0 MIN ";
    }
    
    return [difference stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


@end