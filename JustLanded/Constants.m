//
//  Constants.h
//  Just Landed
//
//  Created by Jon Grall on 2/14/12
//

#import "Constants.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Server Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if defined(LOCAL)
NSString * const BASE_URL = @"http://c-98-207-175-25.hsd1.ca.comcast.net/api/v1";
#else
NSString * const BASE_URL = @"http://just-landed.appspot.com/api/v1";
#endif

NSString * const LOOKUP_URL_FORMAT = @"%@/search/%@";
NSString * const TRACK_URL_FORMAT = @"%@/track/%@/%@?latitude=%.6f&longitude=%.6f&begin_track=%d&push=%d";
NSString * const TRACK_URL_FORMAT_NO_LOC = @"%@/track/%@/%@?begin_track=%d&push=%d";
NSString * const UNTRACK_URL_FORMAT = @"%@/untrack/%@";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark 3rd Party Keys & IDs
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#if defined(LOCAL)
NSString * const FLURRY_APPLICATION_KEY = @"LH6F2XN2C6HAX4NIB3QS";
#else
NSString * const FLURRY_APPLICATION_KEY = @"2TZMR1NGCSTZ395GHUZS";
#endif