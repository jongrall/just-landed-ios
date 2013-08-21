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


+ (NSString *)sanitizeTimeZoneString:(NSString *)tzString {
    tzString = [tzString stringByReplacingOccurrencesOfString:@"-0" withString:@"-"];
    tzString = [tzString stringByReplacingOccurrencesOfString:@"+0" withString:@"+"];
    tzString = [tzString stringByReplacingOccurrencesOfString:@":00" withString:@""];
    return [tzString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


+ (NSString *)naturalDateStringFromDate:(NSDate *)date withTimezone:(NSTimeZone *)tz {
	
	if (date) {
		NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        tz = tz ? tz : localTimeZone;
        NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
        
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        [calendar setTimeZone:tz];
        [calendar setLocale:currentLocale];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:calendar];
        [formatter setTimeZone:tz];
        [formatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        
        // Only show relative dates if same timezone (today, yesterday etc.)
        if ([tz isEqualToTimeZone:localTimeZone]) {
            RelativeDateKind relativeKind = [NSDate currentDateRelativeToDate:date withTimezone:tz];
            
            if (relativeKind == OTHER_DATE) {
                NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EEE MMM d h:mm"
                                                                         options:0
                                                                          locale:currentLocale];
                [formatter setDateFormat:formatString];
                return [formatter stringFromDate:date];
            }
            else {
                // Get relative date
                [formatter setDateStyle:NSDateFormatterShortStyle];
                [formatter setTimeStyle:NSDateFormatterNoStyle];
                [formatter setDoesRelativeDateFormatting:YES];
                NSString *dateString = [formatter stringFromDate:date];
                
                // Styles don't work reliably with 24hr for some reason
                NSString *timeFormat = [NSDateFormatter dateFormatFromTemplate:@"h:mm"
                                                                         options:0
                                                                          locale:currentLocale];
                [formatter setDateFormat:timeFormat];
                NSString *timeString = [formatter stringFromDate:date];
                return [NSString stringWithFormat:@"%@ %@", dateString, timeString];
            }
        }
        else {
            // Append timezone
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMM d h:mm"
                                                                     options:0
                                                                      locale:currentLocale];
            [formatter setDateFormat:formatString];
            NSString *dateTimeString = [formatter stringFromDate:date];
            
            NSString *tzFormatString = [NSDateFormatter dateFormatFromTemplate:@"zzz"
                                                                       options:0
                                                                        locale:currentLocale];
            [formatter setDateFormat:tzFormatString];
            NSString *tzString = [self sanitizeTimeZoneString:[formatter stringFromDate:date]];
            
            return [NSString stringWithFormat:@"%@ %@", dateTimeString, tzString];
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        if (relativeKind == OTHER_DATE) {
            [formatter setCalendar:calendar];
            [formatter setTimeZone:tz];
            [formatter setLocale:currentLocale];
            
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"M/d"
                                                                     options:0
                                                                      locale:[NSLocale autoupdatingCurrentLocale]];
            [formatter setDateFormat:formatString];
            return [formatter stringFromDate:date];
        }
        else {
            // Get relative date
            [formatter setDateStyle:NSDateFormatterShortStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            [formatter setDoesRelativeDateFormatting:YES];
            return [formatter stringFromDate:date];
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
        NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
        tz = tz ? tz : localTimeZone;
        [calendar setTimeZone:tz];
		[calendar setLocale:currentLocale];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:calendar];
		[formatter setTimeZone:tz];
		[formatter setLocale:currentLocale];
        
        NSString *timeFormat = [NSDateFormatter dateFormatFromTemplate:@"h:mm"
                                                               options:0
                                                                locale:currentLocale];
        [formatter setDateFormat:timeFormat];
        NSString *timeString = [formatter stringFromDate:date];
        
        NSString *timezoneFormat = [NSDateFormatter dateFormatFromTemplate:@"zzz"
                                                                   options:0
                                                                    locale:currentLocale];
        [formatter setDateFormat:timezoneFormat];
        NSString *timezoneString = [self sanitizeTimeZoneString:[formatter stringFromDate:date]];
        
        return [NSString stringWithFormat:@"%@ %@", timeString, timezoneString];
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
    NSTimeInterval interval = fabs(round([date timeIntervalSinceNow]));
    
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
    NSTimeInterval interval = fabs(round(anInterval));
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
