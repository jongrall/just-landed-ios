//
//  NSString+JLExtensions.m
//  JustLanded
//
//  Created by Jon on 9/11/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "NSString+JLExtensions.h"

@implementation NSString (JLExtensions)


- (NSString *)urlEncoded {
    NSString *encoded = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                          (__bridge CFStringRef)self,
                                                                          NULL,
                                                                          (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                          kCFStringEncodingUTF8));
    return encoded;
}

- (NSString *)imageName {
    if ([self length] > 0) {
        return [UIScreen isMainScreenWide] ? [NSString stringWithFormat:@"%@-568h", self] : self;
    }
    else {
        return  nil;
    }
}

@end
