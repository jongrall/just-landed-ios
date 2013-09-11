//
//  NSDictionary+JLExtensions.h
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

@import Foundation;

@interface NSDictionary (JLExtensions)

- (id)objectForKeyOrNil:(id)key;
- (id)valueForKeyOrNil:(NSString *)key;
- (id)valueForKeyPathOrNil:(NSString *)keyPath;

@end
