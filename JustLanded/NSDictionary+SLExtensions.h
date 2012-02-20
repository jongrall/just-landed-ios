//
//  NSDictionary+SLExtensions.h
//  Just Landed
//
//  Created by Jon Grall on 2/18/12
//

#import <Foundation/Foundation.h>


@interface NSDictionary (SLExtensions)

- (id)objectForKeyOrNil:(id)key;
- (id)valueForKeyOrNil:(NSString *)key;
- (id)valueForKeyPathOrNil:(NSString *)keyPath;

@end
