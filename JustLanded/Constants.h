//
//  Constants.h
//  Just Landed
//
//  Created by Jon Grall on 2/14/2012.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSUserDefaults & Other Keys
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern NSString * const APP_ID;
extern NSString * const UUIDKey;
extern NSString * const UUIDKey;
extern NSString * const BeganUsingDate;
extern NSString * const ArchivedFlightsFile;
extern NSString * const HasBeenAskedToRateKey;
extern NSString * const FlightsTrackedCountKey;
extern NSString * const RecentAirlineLookupsKey;

// Preferences
extern NSString * const SendFlightEventsPreferenceKey;
extern NSString * const SendRemindersPreferenceKey;
extern NSString * const ReminderLeadTimePreferenceKey;
extern NSString * const PlayFlightSoundsPreferenceKey;
extern NSString * const MonitorLocationPreferenceKey;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Server Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern NSString * const JL_HOST_NAME;
extern NSString * const WEB_HOST;
extern NSString * const BASE_URL;
extern NSUInteger const API_VERSION;
extern NSString * const API_USERNAME;
extern NSString * const API_KEY;
extern NSString * const FAQ_PATH;
extern NSString * const TOS_PATH;
extern NSString * const FNF_ANCHOR;
extern NSString * const HRS48_ANCHOR;
extern NSString * const TWITTER_JL_OPS;
extern NSString * const NATIVE_TWITTER_JL_OPS;
extern NSString * const LOOKUP_URL_FORMAT;
extern NSString * const TRACK_URL_FORMAT;
extern NSString * const UNTRACK_URL_FORMAT;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Misc Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern NSString * JustLandedCurrentRegionIdentifier;
extern double const LOCATION_DISTANCE_FILTER;
extern double const SIGNIFICANT_LOCATION_CHANGE_DISTANCE;
extern double const LOCATION_MAXIMUM_ACCEPTABLE_ERROR;
extern double const LOCATION_MAXIMUM_ACCEPTABLE_AGE;
extern NSTimeInterval const TRACK_FRESHNESS_THRESHOLD;
extern NSUInteger const RATINGS_USAGE_THRESHOLD;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark 3rd Party Keys & IDs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern NSString * const FLURRY_APPLICATION_KEY;
extern NSString * const HOCKEY_APP_ID;

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
extern NSString * const FY_STARTED_SENDING_SMS;
extern NSString * const FY_ABANDONED_SENDING_SMS;
extern NSString * const FY_SENT_SMS;
extern NSString * const FY_STARTED_TWEETING;
extern NSString * const FY_ABANDONED_TWEETING;
extern NSString * const FY_POSTED_TWEET;
extern NSString * const FY_READ_TERMS;
extern NSString * const FY_READ_FAQ;
extern NSString * const FY_VISITED_OPS_FEED;
extern NSString * const FY_ASKED_TO_RATE;
extern NSString * const FY_RATED;
extern NSString * const FY_DECLINED_TO_RATE;
extern NSString * const FY_BEGAN_AIRLINE_LOOKUP;
extern NSString * const FY_CANCELED_AIRLINE_LOOKUP;
extern NSString * const FY_CHOSE_AIRLINE;
extern NSString * const FY_CLEARED_RECENT;

// Errors
extern NSString * const FY_INVALID_FLIGHT_NUM_ERROR;
extern NSString * const FY_OLD_FLIGHT_ERROR;
extern NSString * const FY_FLIGHT_NOT_FOUND_ERROR;
extern NSString * const FY_CURRENT_FLIGHT_NOT_FOUND_ERROR;
extern NSString * const FY_NO_CONNECTION_ERROR;
extern NSString * const FY_SERVER_500;
extern NSString * const FY_OUTAGE;
extern NSString * const FY_UNABLE_TO_GET_LOCATION;
extern NSString * const FY_UNABLE_TO_REGISTER_PUSH;
extern NSString * const FY_BAD_DATA;
