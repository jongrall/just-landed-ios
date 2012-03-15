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

#if defined(CONFIGURATION_Debug)
NSString * const UUIDKey = @"UUIDKeyDev";
NSString * const ARCHIVED_FLIGHTS_FILE = @"FlightsDev.data";
#else
NSString * const UUIDKey = @"UUIDKey";
NSString * const ARCHIVED_FLIGHTS_FILE = @"Flights.data";
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Server Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if defined(CONFIGURATION_Debug)
NSString * const BASE_URL = @"http://c-98-207-175-25.hsd1.ca.comcast.net/api/v1/";
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Development";
NSString * const API_KEY = @"d90816f7e6ea93001a2aa62cd8dd8f0e830a93d1";
#else
NSString * const BASE_URL = @"https://just-landed.appspot.com/api/v1/";
NSUInteger const API_VERSION = 1;
NSString * const API_USERNAME = @"iOS-Production";
NSString * const API_KEY = @"4399d9ce77acf522799543f13c926c0a41e2ea3f";
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
#else
NSString * const FLURRY_APPLICATION_KEY = @"2TZMR1NGCSTZ395GHUZS";
#endif

# if defined (CONFIGURATION_Debug)
NSString * const HOCKEY_APP_ID = @"NOT_USED"; //Not used in dev
#elif defined(CONFIGURATION_Adhoc)
NSString * const HOCKEY_APP_ID = @"5a0221e1a7ebd7fe6e01c4742bea58c8";
#elif defined (CONFIGURATION_Release)
NSString * const HOCKEY_APP_ID = @"";
#endif


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocation Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CLLocationDistance const DesiredLocationAccuracy = 150.0;
NSTimeInterval const DesiredLocationFreshness = 120.0;