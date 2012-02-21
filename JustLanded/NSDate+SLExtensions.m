//
//  NSDate+SLExtensions.m
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//

#import "NSDate+SLExtensions.h"


@implementation NSDate (SLExtensions)

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
	if (timestamp && [timestamp isKindOfClass:[NSNumber class]]) {
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


@end