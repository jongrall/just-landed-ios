//
//  Constants.h
//  Just Landed
//
//  Created by Jon Grall on 2/14/12
//

#import "Constants.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSUserDefaults Keys
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * const APP_ID = @"500379361";

#if defined(CONFIGURATION_Debug)
NSString * const UUIDKey = @"UUIDKeyDev";
NSString * const ARCHIVED_FLIGHTS_FILE = @"FlightsDev.data";
NSString * const HasBeenAskedToRateKey = @"HasBeenAskedToRateKeyDev";
NSString * const FlightsTrackedCountKey = @"FlightsTrackedCountKeyDev";
#elif defined(CONFIGURATION_Adhoc)
NSString * const UUIDKey = @"UUIDKeyStaging";
NSString * const ARCHIVED_FLIGHTS_FILE = @"FlightsStaging.data";
NSString * const HasBeenAskedToRateKey = @"HasBeenAskedToRateKeyStaging";
NSString * const FlightsTrackedCountKey = @"FlightsTrackedCountKeyStaging";
#else
NSString * const UUIDKey = @"UUIDKey";
NSString * const ARCHIVED_FLIGHTS_FILE = @"Flights.data";
NSString * const HasBeenAskedToRateKey = @"HasBeenAskedToRateKey";
NSString * const FlightsTrackedCountKey = @"FlightsTrackedCountKey";
#endif

NSUInteger const RATINGS_USAGE_THRESHOLD = 5;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Server Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if defined(CONFIGURATION_Debug)
NSString * const BASE_URL = @"http://c-98-207-175-25.hsd1.ca.comcast.net/api/v1/";
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Development";
NSString * const API_KEY = @"d90816f7e6ea93001a2aa62cd8dd8f0e830a93d1";
NSString * const FAQ_URL = @"http://c-98-207-175-25.hsd1.ca.comcast.net/iphonefaq";
#elif defined(CONFIGURATION_Adhoc)
NSString * const BASE_URL = @"https://just-landed-staging.appspot.com/api/v1/";
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Staging";
NSString * const API_KEY = @"55ca8681039e129bb985991014f61774de31fe1e";
NSString * const FAQ_URL = @"http://just-landed-staging.appspot.com/iphonefaq";
#else
NSString * const BASE_URL = @"https://just-landed.appspot.com/api/v1/";
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Production";
NSString * const API_KEY = @"4399d9ce77acf522799543f13c926c0a41e2ea3f";
NSString * const FAQ_URL = @"http://www.getjustlanded.com/iphonefaq";
#endif

NSString * const LOOKUP_URL_FORMAT = @"search/%@";
NSString * const TRACK_URL_FORMAT = @"track/%@/%@";
NSString * const UNTRACK_URL_FORMAT = @"untrack/%@";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark 3rd Party Keys & IDs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#if defined(CONFIGURATION_Debug)
NSString * const FLURRY_APPLICATION_KEY = @"LH6F2XN2C6HAX4NIB3QS";
NSString * const HOCKEY_APP_ID = @"NOT_USED"; //Not used in dev
#elif defined(CONFIGURATION_Adhoc)
NSString * const FLURRY_APPLICATION_KEY = @"JICB45DI2N7ZE2B4FR5E";
NSString * const HOCKEY_APP_ID = @"5a0221e1a7ebd7fe6e01c4742bea58c8";
#else
NSString * const FLURRY_APPLICATION_KEY = @"2TZMR1NGCSTZ395GHUZS";
NSString * const HOCKEY_APP_ID = @"d3afd0c1d0a5b5b73980f097c40b77a8";
#endif


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocation Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CLLocationDistance const DesiredLocationAccuracy = 150.0;
NSTimeInterval const DesiredLocationFreshness = 120.0;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Reporting / Analytics Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * const FY_LOOKED_UP_FLIGHT = @"Looked Up Flight";
NSString * const FY_BEGAN_TRACKING_FLIGHT = @"Began Tracking Flight";
NSString * const FY_GOT_DIRECTIONS = @"Got Directions";
NSString * const FY_STOPPED_TRACKING_FLIGHT = @"Stopped Tracking Flight";
NSString * const FY_VISITED_ABOUT_SCREEN = @"Visited About Screen";
NSString * const FY_STARTED_SENDING_FEEDBACK = @"Started Sending Feedback";
NSString * const FY_ABANDONED_SENDING_FEEDBACK = @"Abandoned Sending Feedback";
NSString * const FY_SENT_FEEDBACK = @"Sent Feedback";
NSString * const FY_STARTED_TWEETING = @"Started Tweeting"; 
NSString * const FY_ABANDONED_TWEETING = @"Abandoned Tweeting";
NSString * const FY_POSTED_TWEET = @"Posted Tweet";
NSString * const FY_VISITED_WEBSITE = @"Visited Website";
NSString * const FY_READ_FAQ = @"Read FAQ";
NSString * const FY_ASKED_TO_RATE = @"Asked to Rate App";
NSString * const FY_RATED = @"Rated App";
NSString * const FY_DECLINED_TO_RATE = @"Declined to Rate App";

// Errors
NSString * const FY_INVALID_FLIGHT_NUM_ERROR = @"Invalid Flight Number";
NSString * const FY_OLD_FLIGHT_ERROR = @"Old Flight";
NSString * const FY_FLIGHT_NOT_FOUND_ERROR = @"Flight Not Found";
NSString * const FY_NO_CONNECTION_ERROR = @"No Connection";
NSString * const FY_SERVER_500 = @"500 Error";
NSString * const FY_UNABLE_TO_GET_LOCATION = @"Unable to Get Location";
NSString * const FY_UNABLE_TO_REGISTER_PUSH = @"Unable to Register for Notifications";