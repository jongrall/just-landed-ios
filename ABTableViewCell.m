// Copyright (c) 2008 Loren Brichter
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
//  ABTableViewCell.m
//
//  Created by Loren Brichter
//  Copyright 2008 Loren Brichter. All rights reserved.
//

#import "ABTableViewCell.h"
#import "Constants.h"

@interface ABTableViewCellContentView : UIView
@property (weak, nonatomic) ABTableViewCell *parentCell;
@end

@implementation ABTableViewCellContentView

- (id)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		self.contentMode = UIViewContentModeRedraw;
	}

	return self;
}

@end


@interface ABTableViewCellView : ABTableViewCellContentView
@end

@implementation ABTableViewCellView

- (void)drawRect:(CGRect)rect {
    ABTableViewCell *theParentCell = self.parentCell;
	[theParentCell drawContentView:rect highlighted:NO];
}

@end


@interface ABTableViewSelectedCellView : ABTableViewCellContentView
@end

@implementation ABTableViewSelectedCellView

- (void)drawRect:(CGRect)rect {
    ABTableViewCell *theParentCell = self.parentCell;
	[theParentCell drawContentView:rect highlighted:YES];
}


- (CGRect)frame {
    ABTableViewCell *theParentCell = self.parentCell;
    return theParentCell.backgroundView.frame;
}


- (void)setFrame:(CGRect)frame {
    ABTableViewCell *theParentCell = self.parentCell;
    [super setFrame:theParentCell.backgroundView.frame];
}

@end


@implementation ABTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        ABTableViewCellView *cellView = [[ABTableViewCellView alloc] initWithFrame:CGRectZero];
        cellView.parentCell = self;
		contentView = cellView;
		contentView.opaque = YES;
		self.backgroundView = contentView;

        ABTableViewSelectedCellView *selectedCellView = [[ABTableViewSelectedCellView alloc] initWithFrame:CGRectZero];
        selectedCellView.parentCell = self;
		selectedContentView = selectedCellView;
		selectedContentView.opaque = YES;
		self.selectedBackgroundView = selectedContentView;
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected {
	[selectedContentView setNeedsDisplay];
	
	if(!selected && self.selected) {
		[contentView setNeedsDisplay];
	}
	
	[super setSelected:selected];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[selectedContentView setNeedsDisplay];

	if(!selected && self.selected) {
		[contentView setNeedsDisplay];
	}
	
	[super setSelected:selected animated:animated];
}


- (void)setHighlighted:(BOOL)highlighted {
	[selectedContentView setNeedsDisplay];

	if(!highlighted && self.highlighted) {
		[contentView setNeedsDisplay];
	}
	
	[super setHighlighted:highlighted];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[selectedContentView setNeedsDisplay];
	
	if(!highlighted && self.highlighted) {
		[contentView setNeedsDisplay];
	}
	
	[super setHighlighted:highlighted animated:animated];
}


- (void)setFrame:(CGRect)f {
	[super setFrame:f];
	CGRect b = [self bounds];
	[contentView setFrame:b];
	[selectedContentView setFrame:b];
}


- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];

	if([self isHighlighted] || [self isSelected]) {
		[selectedContentView setNeedsDisplay];
	}
}


- (void)setNeedsDisplayInRect:(CGRect)rect {
	[super setNeedsDisplayInRect:rect];
    [contentView setNeedsDisplayInRect:rect];
	
	if([self isHighlighted] || [self isSelected]) {
		[selectedContentView setNeedsDisplayInRect:rect];
	}
}


- (void)layoutSubviews {
	[super layoutSubviews];
	self.contentView.hidden = YES;
	[self.contentView removeFromSuperview];
}


- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Subclasses must override %@",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
