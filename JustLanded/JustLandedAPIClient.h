//
//  JustLandedAPIClient.h
//  JustLanded
//
//  Created by Jon Grall on 2/17/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"


@interface JustLandedAPIClient : AFHTTPClient

+ (JustLandedAPIClient *)sharedClient;

@end
