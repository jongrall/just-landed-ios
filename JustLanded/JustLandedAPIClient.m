//
//  JustLandedAPIClient.m
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//

#import "JustLandedAPIClient.h"
#import "AFJSONRequestOperation.h"

@implementation JustLandedAPIClient

+ (JustLandedAPIClient *)sharedClient {
    static JustLandedAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    });
    
    return _sharedClient;
}


+ (NSString *)lookupPathWithFlightNumber:(NSString *)flightNumber {
    return [[NSString stringWithFormat:LOOKUP_URL_FORMAT, flightNumber] 
            stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];;
}


+ (NSString *)trackPathWithFlightNumber:(NSString *)flightNumber flightID:(NSString *)flightID {
    return [[NSString stringWithFormat:TRACK_URL_FORMAT, flightNumber, flightID] 
            stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}


+ (NSString *)stopTrackingPathWithFlightID:(NSString *)flightID {
    return [[NSString stringWithFormat:UNTRACK_URL_FORMAT, flightID]
            stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    // Override accepted languages
    [self setDefaultHeader:@"Accept-Language" value:@"en, en-us;q=0.8"];
    
    // X-Just-Landed-API-Key HTTP Header
	//[self setDefaultHeader:@"X-Just-Landed-API-Key" value:@"foo"];
	
	// X-Just-Landed-API-Version HTTP Header
	[self setDefaultHeader:@"X-Just-Landed-API-Version" value:@"1"];
	
	// X-UUID HTTP Header
	[self setDefaultHeader:@"X-Just-Landed-UUID" value:[[JustLandedSession sharedSession] UUID]];
    
    return self;
}

@end
