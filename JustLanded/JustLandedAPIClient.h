//
//  JustLandedAPIClient.h
//  Just Landed
//
//  Created by Jon Grall on 2/17/12
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"


@interface JustLandedAPIClient : AFHTTPClient

+ (JustLandedAPIClient *)sharedClient;

@end
