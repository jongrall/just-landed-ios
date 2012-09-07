//
//  Just LandedAPIClient.m
//  Just Landed
//
//  Created by Jon Grall on 2/17/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JustLandedAPIClient.h"
#import "AFJSONRequestOperation.h"
#import <CommonCrypto/CommonHMAC.h>

@interface JustLandedAPIClient ()

+ (NSString *)apiRequestSignatureWithPath:(NSString *)path params:(NSDictionary *)params;

@end


@implementation JustLandedAPIClient

+ (JustLandedAPIClient *)sharedClient {
    static JustLandedAPIClient *sharedClient_ = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedClient_ = [[self alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    });
    
    return sharedClient_;
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


+ (NSString *)apiRequestSignatureWithPath:(NSString *)path params:(NSDictionary *)params {
    // Sort the parameter keys
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedValues = [params objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<[sortedKeys count]; i++) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", [sortedKeys objectAtIndex:i],
                          [sortedValues objectAtIndex:i]]];
    }
    
    NSString *to_sign;
    
    if ([parts count] > 0) {
        to_sign = [NSString stringWithFormat:@"/api/v%d/%@?%@", API_VERSION, path, [parts componentsJoinedByString:@"&"]];
    }
    else {
        to_sign = [NSString stringWithFormat:@"/api/v%d/%@", API_VERSION, path];
    }
    
    const char *cKey = [API_KEY cStringUsingEncoding:NSASCIIStringEncoding];
	const char *cData = [to_sign cStringUsingEncoding:NSASCIIStringEncoding];
	
	unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1,
		   cKey,
		   strlen(cKey),
		   cData,
		   strlen(cData),
		   cHMAC);
    
    NSData *dataFromHMAC = [NSData dataWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    return [[dataFromHMAC hexString] lowercaseString];
}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        // Override accepted languages
        [self setDefaultHeader:@"Accept-Language" value:@"en, en-us;q=0.8"];
        
        // X-Just-Landed-API-Client HTTP Header
        [self setDefaultHeader:@"X-Just-Landed-API-Client" value:API_USERNAME];
        
        // X-Just-Landed-API-Version HTTP Header
        [self setDefaultHeader:@"X-Just-Landed-API-Version" value:[NSString stringWithFormat:@"%d", API_VERSION]];
        
        // X-UUID HTTP Header
        [self setDefaultHeader:@"X-Just-Landed-UUID" value:[[JustLandedSession sharedSession] UUID]];
        
        // X-Just-Landed-App-Version HTTP Header
        [self setDefaultHeader:@"X-Just-Landed-App-Version"
                         value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    }
    
    return self;
}


- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(AFHTTPRequestOperation *, id))success 
        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    // Override to set custom timeout
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    [request setTimeoutInterval:15];
    
    // Sign the request
    NSString *sig = [[self class] apiRequestSignatureWithPath:path params:parameters];
    [request setValue:sig forHTTPHeaderField:@"X-Just-Landed-Signature"];
    
    // Set the language (can change between requests)
    [request setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forHTTPHeaderField:@"X-Just-Landed-User-Language"];
    
    // Force gzip encoding from GAE
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"gzip" forHTTPHeaderField:@"User-Agent"];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:success
                                                                      failure:failure];
    
    [self enqueueHTTPRequestOperation:operation];
}



@end
