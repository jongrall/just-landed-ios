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
        
        self.placeholder = NSLocalizedString(@"ex. VX29", @"Flight number input placeholder");
        self.backgroundColor = [UIColor clearColor];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.borderStyle = UITextBorderStyleNone;
        
        errorState_ = FlightInputNoError;
        LabelStyle *labelStyle = [JLLookupStyles flightFieldTextStyle];
        TextStyle *textStyle = labelStyle.textStyle;
        self.textAlignment = labelStyle.alignment;
        self.font = textStyle.font;
        self.textColor = textStyle.color;
        
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


- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 143.0f, bounds.origin.y + 15.0f, bounds.size.width - 170.0f, 30.0f);
}


- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 143.0f, bounds.origin.y + 14.0f, bounds.size.width - 170.0f, 30.0f);
}


- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 143.0f, bounds.origin.y + 15.0f, bounds.size.width - 170.0f, 30.0f);
}


- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 14.0f, 0.0f, 120.0f, 40.0f);
}

@end
