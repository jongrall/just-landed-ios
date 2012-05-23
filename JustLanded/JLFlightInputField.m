//
//  JLFlightInputField.m
//  JustLanded
//
//  Created by Jon Grall on 4/22/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLFlightInputField.h"

@implementation JLFlightInputField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        LabelStyle *leftViewStyle = [JLLookupStyles flightFieldLabelStyle];
        LabelStyle *textLabelStyle = [JLLookupStyles flightFieldTextStyle];
        TextStyle *textStyle = [textLabelStyle textStyle];
        
        self.placeholder = NSLocalizedString(@"ex. AA320", @"Flight number input placeholder");
        self.backgroundColor = [UIColor clearColor];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.textAlignment = [textLabelStyle alignment];
        self.borderStyle = UITextBorderStyleNone;
        self.font = [textStyle font];
        self.textColor = [textStyle color];
        self.clearsOnBeginEditing = NO;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.keyboardType = UIKeyboardTypeNamePhonePad;
        self.adjustsFontSizeToFitWidth = NO;
        
        JLLabel *leftLabel = [[JLLabel alloc] initWithLabelStyle:leftViewStyle frame:LOOKUP_LABEL_TEXT_FRAME];
        leftLabel.text = NSLocalizedString(@"FLIGHT #", @"FLIGHT #");
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lookup_input_divider"]];
        separator.frame = CGRectMake(LOOKUP_SEPARATOR_ORIGIN.x, 
                                     LOOKUP_SEPARATOR_ORIGIN.y,
                                     separator.frame.size.width,
                                     separator.frame.size.height);
        
        UIView *container = [[UIView alloc] initWithFrame:LOOKUP_LABEL_FRAME];
        
        [container addSubview:leftLabel];
        [container addSubview:separator];
        
        self.leftView = container;
        self.leftView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
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
