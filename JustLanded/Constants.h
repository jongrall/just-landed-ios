//
//  Constants.h
//  Just Landed
//
//  Created by Jon Grall on 2/14/2012.
//

#import <CoreLocation/CoreLocation.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSUserDefaults & Other Keys
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern NSString * const APP_ID;
extern NSString * const UUIDKey;
extern NSString * const ARCHIVED_FLIGHTS_FILE;
extern NSString * const HasBeenAskedToRateKey;
extern NSString * const FlightsTrackedCountKey;
extern NSUInteger const RATINGS_USAGE_THRESHOLD;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Server Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


extern NSString * const BASE_URL;
extern NSString * const LOOKUP_URL_FORMAT;
extern NSString * const TRACK_URL_FORMAT;
extern NSString * const UNTRACK_URL_FORMAT;
extern NSUInteger const API_VERSION;
extern NSString * const API_USERNAME;
extern NSString * const API_KEY;
extern NSString * const FAQ_URL;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark 3rd Party Keys & IDs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


extern NSString * const FLURRY_APPLICATION_KEY;
extern NSString * const HOCKEY_APP_ID;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocation Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


extern CLLocationDistance const DesiredLocationAccuracy;
extern NSTimeInterval const DesiredLocationFreshness;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Reporting / Analytics Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern NSString * const FY_LOOKED_UP_FLIGHT;
extern NSString * const FY_BEGAN_TRACKING_FLIGHT;
extern NSString * const FY_GOT_DIRECTIONS;
extern NSString * const FY_STOPPED_TRACKING_FLIGHT;
extern NSString * const FY_VISITED_ABOUT_SCREEN;
extern NSString * const FY_STARTED_SENDING_FEEDBACK;
extern NSString * const FY_ABANDONED_SENDING_FEEDBACK;
extern NSString * const FY_SENT_FEEDBACK;
extern NSString * const FY_STARTED_TWEETING;
extern NSString * const FY_ABANDONED_TWEETING;
extern NSString * const FY_POSTED_TWEET;
extern NSString * const FY_VISITED_WEBSITE;
extern NSString * const FY_READ_FAQ;
extern NSString * const FY_ASKED_TO_RATE;
extern NSString * const FY_RATED;
extern NSString * const FY_DECLINED_TO_RATE;

// Errors
extern NSString * const FY_INVALID_FLIGHT_NUM_ERROR;
extern NSString * const FY_OLD_FLIGHT_ERROR;
extern NSString * const FY_FLIGHT_NOT_FOUND_ERROR;
extern NSString * const FY_NO_CONNECTION_ERROR;
extern NSString * const FY_SERVER_500;
extern NSString * const FY_UNABLE_TO_GET_LOCATION;
extern NSString * const FY_UNABLE_TO_REGISTER_PUSH;