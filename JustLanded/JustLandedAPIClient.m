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
    static JustLandedAPIClient *sSharedClient_ = nil;
    static dispatch_once_t sOncePredicate;
    
    dispatch_once(&sOncePredicate, ^{
        sSharedClient_ = [[self alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    });
    
    return sSharedClient_;
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
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wselector"
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    #pragma clang diagnostic pop
    NSArray *sortedValues = [params objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i<[sortedKeys count]; i++) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", sortedKeys[i],
                          sortedValues[i]]];
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
        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Accept-Language" value:@"en, en-us;q=0.8"];
        [self setDefaultHeader:@"X-Just-Landed-API-Client" value:API_USERNAME];
        [self setDefaultHeader:@"X-Just-Landed-API-Version" value:[NSString stringWithFormat:@"%d", API_VERSION]];
        [self setDefaultHeader:@"X-Just-Landed-UUID" value:[[JustLandedSession sharedSession] UUID]];
        [self setDefaultHeader:@"X-Just-Landed-App-Version"
                         value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    }
    
    return self;
}


- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(AFHTTPRequestOperation *, id))success 
        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    // Set custom timeout
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    [request setTimeoutInterval:20];
    
    // Sign the request
    NSString *sig = [[self class] apiRequestSignatureWithPath:path params:parameters];
    [request setValue:sig forHTTPHeaderField:@"X-Just-Landed-Signature"];
    
    // Set the language (can change between requests)
    [request setValue:[NSLocale preferredLanguages][0] forHTTPHeaderField:@"X-Just-Landed-User-Language"];
    
    // Force gzip encoding from GAE
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"gzip" forHTTPHeaderField:@"User-Agent"];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:success
                                                                      failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

@end
