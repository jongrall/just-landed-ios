//
//  JLFlightInputField.m
//  Just Landed
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLFlightInputField.h"

@implementation JLFlightInputField

@synthesize errorState = errorState_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        LabelStyle *leftViewStyle = [JLLookupStyles flightFieldLabelStyle];
        errorState_ = FlightInputNoError;
        LabelStyle *labelStyle = [JLLookupStyles flightFieldTextStyle];
        TextStyle *textStyle = labelStyle.textStyle;

        self.placeholder = NSLocalizedString(@"ex. VX29", @"Flight number input placeholder");
        self.backgroundColor = [UIColor clearColor];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.borderStyle = UITextBorderStyleNone;

        self.textAlignment = labelStyle.alignment;
        self.font = textStyle.font;
        self.textColor = textStyle.color;

        if ([self respondsToSelector:@selector(tintColor)]) {
            self.tintColor = [JLLookupStyles lookupFieldTintColor];
        }

        self.clearsOnBeginEditing = NO;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.keyboardType = UIKeyboardTypeNamePhonePad;
        self.adjustsFontSizeToFitWidth = NO;

        JLLabel *leftLabel = [[JLLabel alloc] initWithLabelStyle:leftViewStyle
                                                           frame:[JLLookupStyles lookupLabelTextFrame]];
        leftLabel.text = NSLocalizedString(@"FLIGHT #", @"FLIGHT #");
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lookup_input_divider"]];
        CGPoint separatorOrigin = [JLLookupStyles lookupSeparatorOrigin];
        separator.frame = CGRectMake(separatorOrigin.x,
                                     separatorOrigin.y,
                                     separator.frame.size.width,
                                     separator.frame.size.height);
        
        UIView *container = [[UIView alloc] initWithFrame:[JLLookupStyles lookupLabelFrame]];
        
        [container addSubview:leftLabel];
        [container addSubview:separator];
        
        self.leftView = container;
        self.leftView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}


- (void)setErrorState:(FlightInputErrorState)aState {
        errorState_ = aState;
        LabelStyle *labelStyle = nil;
            
        // Change the text style based on the error state
        switch (errorState_) {
            case FlightInputError: {
                labelStyle = [JLLookupStyles flightFieldErrorTextStyle];
                break;
            }
            default: {
                labelStyle = [JLLookupStyles flightFieldTextStyle];
                break;
            }
        }
        
        TextStyle *textStyle = labelStyle.textStyle;
        self.textAlignment = labelStyle.alignment;
        self.font = textStyle.font;
        self.textColor = textStyle.color;
}


- (void)drawPlaceholderInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    LabelStyle *labelStyle = [JLLookupStyles flightFieldTextStyle];
    TextStyle *textStyle = labelStyle.textStyle;

    if (!iOS_6_OrEarlier()) {
        rect = CGRectMake(rect.origin.x, rect.origin.y + 15.5f, rect.size.width, rect.size.height);
    }

    CGContextClearRect(context, rect);

    // Draw the placeholder text
    [[UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0f] set];
    [self.placeholder drawInRect:rect
                        withFont:textStyle.font
                   lineBreakMode:labelStyle.lineBreakMode
                       alignment:labelStyle.alignment];
}


- (CGRect)textRectForBounds:(CGRect)bounds {
    if (iOS_6_OrEarlier()) {
        return CGRectMake(bounds.origin.x + 143.0f, bounds.origin.y + 15.0f, bounds.size.width - 170.0f, 30.0f);
    } else {
        CGRect textRect = [super textRectForBounds:bounds];
        return CGRectMake(textRect.origin.x + 9.0f,
                          textRect.origin.y + 2.0f,
                          textRect.size.width -9.0f,
                          textRect.size.height);
    }
}


- (CGRect)editingRectForBounds:(CGRect)bounds {
    if (iOS_6_OrEarlier()) {
        return CGRectMake(bounds.origin.x + 143.0f, bounds.origin.y + 14.0f, bounds.size.width - 170.0f, 30.0f);
    } else {
        CGRect editingRect = [super editingRectForBounds:bounds];
        return CGRectMake(editingRect.origin.x + 9.0f,
                          editingRect.origin.y + 2.0f,
                          editingRect.size.width - 9.0f,
                          editingRect.size.height);
    }
}


- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    if (iOS_6_OrEarlier()) {
        return CGRectMake(bounds.origin.x + 143.0f, bounds.origin.y + 15.0f, bounds.size.width - 170.0f, 30.0f);
    } else {
        CGRect placeholderRect = [super placeholderRectForBounds:bounds];
        return CGRectMake(placeholderRect.origin.x,
                          placeholderRect.origin.y - 2.0f,
                          placeholderRect.size.width,
                          placeholderRect.size.height);
    }
}


- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 14.0f, 0.0f, 120.0f, 40.0f);
}

@end
