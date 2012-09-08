//
//  LabelStyle.m
//  Just Landed
//
//  Created by Jon Grall on 4/13/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "LabelStyle.h"

@interface LabelStyle ()

// Redefine as readwrite
@property (strong, readwrite, nonatomic) TextStyle *textStyle;
@property (strong, readwrite, nonatomic) UIColor *backgroundColor;
@property (readwrite, nonatomic) UITextAlignment alignment;
@property (readwrite, nonatomic) UILineBreakMode lineBreakMode;

@end


@implementation LabelStyle

- (id)init {
    return [self initWithTextStyle:[[TextStyle alloc] init]
                   backgroundColor:nil
                         alignment:UITextAlignmentLeft
                     lineBreakMode:UILineBreakModeTailTruncation];
}


- (id)initWithTextStyle:(TextStyle *)style
        backgroundColor:(UIColor *)aColor
              alignment:(UITextAlignment)anAlignment
          lineBreakMode:(UILineBreakMode)aMode {
    NSAssert(style != nil, @"LabelStyle requires a TextStyle.");
    self = [super init];
    
    if (self) {
        self.textStyle = style;
        self.alignment = anAlignment;
        self.lineBreakMode = aMode;
        
        if (aColor != nil) {
            self.backgroundColor = aColor;
        }
        else {
            self.backgroundColor = [UIColor clearColor];
        }
    }
    
    return self;
}

@end
