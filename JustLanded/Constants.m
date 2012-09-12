//
//  Constants.m
//  Just Landed
//
//  Created by Jon Grall on 2/14/12
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "Constants.h"
#include "TargetConditionals.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSUserDefaults Keys
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * const APP_ID = @"520338005";

#if defined(CONFIGURATION_Debug)
NSString * const UUIDKey = @"UUIDKeyDev";
NSString * const BeganUsingDate = @"BeganUsingKeyDev";
NSString * const ArchivedFlightsFile = @"FlightsDev.data";
NSString * const HasBeenAskedToRateKey = @"HasBeenAskedToRateKeyDev";
NSString * const FlightsTrackedCountKey = @"FlightsTrackedCountKeyDev";
NSString * const RecentAirlineLookupsKey = @"RecentLookupsKey-Development";
#elif defined(CONFIGURATION_Adhoc)
NSString * const UUIDKey = @"UUIDKeyStaging";
NSString * const BeganUsingDate = @"BeganUsingKeyStaging";
NSString * const ArchivedFlightsFile = @"FlightsStaging.data";
NSString * const HasBeenAskedToRateKey = @"HasBeenAskedToRateKeyStaging";
NSString * const FlightsTrackedCountKey = @"FlightsTrackedCountKeyStaging";
NSString * const RecentAirlineLookupsKey = @"RecentLookupsKey-Adhoc";
#else
NSString * const UUIDKey = @"UUIDKey";
NSString * const BeganUsingDate = @"BeganUsingKey";
NSString * const ArchivedFlightsFile = @"Flights.data";
NSString * const HasBeenAskedToRateKey = @"HasBeenAskedToRateKey";
NSString * const FlightsTrackedCountKey = @"FlightsTrackedCountKey";
NSString * const RecentAirlineLookupsKey = @"RecentLookupsKey-Production";
#endif

// Preferences
NSString * const SendFlightEventsPreferenceKey = @"send_flight_events";
NSString * const SendRemindersPreferenceKey = @"send_reminders";
NSString * const ReminderLeadTimePreferenceKey = @"reminder_lead_time";
NSString * const PlayFlightSoundsPreferenceKey = @"play_flight_sounds";
NSString * const MonitorLocationPreferenceKey = @"monitor_location";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Server Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if defined(CONFIGURATION_Debug)
    #if TARGET_IPHONE_SIMULATOR
        NSString * const JL_HOST_NAME = @"localhost";
        NSString * const WEB_HOST = @"http://localhost:8082";
        NSString * const BASE_URL = @"http://localhost:8082/api/v1/";
    #else
        NSString * const JL_HOST_NAME = @"c-98-207-175-25.hsd1.ca.comcast.net";
        NSString * const WEB_HOST = @"http://c-98-207-175-25.hsd1.ca.comcast.net:8082";
        NSString * const BASE_URL = @"http://c-98-207-175-25.hsd1.ca.comcast.net:8082/api/v1/";
    #endif
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Development";
NSString * const API_KEY = @"d90816f7e6ea93001a2aa62cd8dd8f0e830a93d1";
#elif defined(CONFIGURATION_Adhoc)
NSString * const JL_HOST_NAME = @"just-landed-staging.appspot.com";
NSString * const WEB_HOST = @"http://just-landed-staging.appspot.com";
NSString * const BASE_URL = @"https://just-landed-staging.appspot.com/api/v1/";
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Staging";
NSString * const API_KEY = @"55ca8681039e129bb985991014f61774de31fe1e";
#else
NSString * const JL_HOST_NAME = @"just-landed.appspot.com";
NSString * const WEB_HOST = @"http://www.getjustlanded.com";
NSString * const BASE_URL = @"https://just-landed.appspot.com/api/v1/";
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Production";
NSString * const API_KEY = @"4399d9ce77acf522799543f13c926c0a41e2ea3f";
#endif

NSString * const FAQ_PATH = @"/iphonefaq";
NSString * const TOS_PATH = @"/terms";
NSString * const FNF_ANCHOR = @"#flightnotfound";
NSString * const HRS48_ANCHOR = @"#48hrs";
NSString * const TWITTER_JL_OPS = @"https://mobile.twitter.com/JustLandedOps/tweets";
NSString * const NATIVE_TWITTER_JL_OPS = @"twitter://user?screen_name=JustLandedOps";
NSString * const LOOKUP_URL_FORMAT = @"search/%@";
NSString * const TRACK_URL_FORMAT = @"track/%@/%@";
NSString * const UNTRACK_URL_FORMAT = @"untrack/%@";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Misc Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * JustLandedCurrentRegionIdentifier = @"JustLandedCurrentRegionIdentifier";
double const LOCATION_DISTANCE_FILTER = 100.0; // Must move 100m for location event to be delivered
double const SIGNIFICANT_LOCATION_CHANGE_DISTANCE = 400.0; // 0.25mi Distance that we consider a significant location change
double const LOCATION_MAXIMUM_ACCEPTABLE_ERROR = 100.0; // Horizontal accuracy we're looking for
double const LOCATION_MAXIMUM_ACCEPTABLE_AGE = 60.0; // When fetching fresh location, 1 min old is max acceptable amount
NSTimeInterval const TRACK_FRESHNESS_THRESHOLD = 900.0;
NSUInteger const RATINGS_USAGE_THRESHOLD = 3;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark 3rd Party Keys & IDs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if defined(CONFIGURATION_Debug)
NSString * const FLURRY_APPLICATION_KEY = @"LH6F2XN2C6HAX4NIB3QS";
NSString * const HOCKEY_APP_ID = @"NOT_USED"; //Not used in dev
#elif defined(CONFIGURATION_Adhoc)
NSString * const FLURRY_APPLICATION_KEY = @"JICB45DI2N7ZE2B4FR5E";
NSString * const HOCKEY_APP_ID = @"26ac1cc044e6688556dfc9d99492ea46";
#else
NSString * const FLURRY_APPLICATION_KEY = @"2TZMR1NGCSTZ395GHUZS";
NSString * const HOCKEY_APP_ID = @"9f84215688008ed9d76a6ace2d8eccd3";
#endif

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
NSString * const FY_STARTED_SENDING_SMS = @"Started Sending SMS";
NSString * const FY_ABANDONED_SENDING_SMS = @"Abandoned Sending SMS";
NSString * const FY_SENT_SMS = @"Sent SMS";
NSString * const FY_STARTED_TWEETING = @"Started Tweeting"; 
NSString * const FY_ABANDONED_TWEETING = @"Abandoned Tweeting";
NSString * const FY_POSTED_TWEET = @"Posted Tweet";
NSString * const FY_READ_TERMS = @"Read Terms";
NSString * const FY_READ_FAQ = @"Read FAQ";
NSString * const FY_VISITED_OPS_FEED = @"Visited JustLandedOps Feed";
NSString * const FY_ASKED_TO_RATE = @"Asked to Rate App";
NSString * const FY_RATED = @"Rated App";
NSString * const FY_DECLINED_TO_RATE = @"Declined to Rate App";
NSString * const FY_BEGAN_AIRLINE_LOOKUP = @"Began Airline Lookup";
NSString * const FY_CANCELED_AIRLINE_LOOKUP = @"Canceled Airline Lookup";
NSString * const FY_CHOSE_AIRLINE = @"Chose Airline";
NSString * const FY_CLEARED_RECENT = @"Cleared Recent Airlines";

// Errors
NSString * const FY_INVALID_FLIGHT_NUM_ERROR = @"Invalid Flight Number";
NSString * const FY_OLD_FLIGHT_ERROR = @"Old Flight";
NSString * const FY_FLIGHT_NOT_FOUND_ERROR = @"Flight Not Found";
NSString * const FY_CURRENT_FLIGHT_NOT_FOUND_ERROR = @"Current Flight Not Found";
NSString * const FY_NO_CONNECTION_ERROR = @"No Connection";
NSString * const FY_SERVER_500 = @"500 Error";
NSString * const FY_OUTAGE = @"Service Outage";
NSString * const FY_UNABLE_TO_GET_LOCATION = @"Unable to Get Location";
NSString * const FY_UNABLE_TO_REGISTER_PUSH = @"Unable to Register for Notifications";
NSString * const FY_BAD_DATA = @"Bad Data";
