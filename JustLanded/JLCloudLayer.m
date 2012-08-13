//
//  JLCloudLayer.m
//  Just Landed
//
//  Created by Jon Grall on 4/23/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLCloudLayer.h"

// Points per second speed of each layer
const CGFloat LAYER1_SPEED = 20.0f;
const CGFloat LAYER2_SPEED = 15.0f;
const CGFloat LAYER3_SPEED = 10.0f;
const CGFloat LAYER4_SPEED = 5.0f;


@interface JLCloudLayer () {
    __strong UIScrollView *_layer1;
    __strong UIScrollView *_layer2;
    __strong UIScrollView *_layer3;
    __strong UIScrollView *_layer4;
    __strong NSTimer *_animationTimer;
    CGFloat _layer1Offset;
    CGFloat _layer2Offset;
    CGFloat _layer3Offset;
    CGFloat _layer4Offset;
}

- (void)animationTick;
- (UIScrollView *)cloudLayerScrollViewWithRepeatingImage:(UIImage *)image;

@end


@implementation JLCloudLayer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *clouds1 = [UIImage imageNamed:@"lookup_clouds_1"];
        UIImage *clouds2 = [UIImage imageNamed:@"lookup_clouds_2"];
        UIImage *clouds3 = [UIImage imageNamed:@"lookup_clouds_3"];
        UIImage *clouds4 = [UIImage imageNamed:@"lookup_clouds_4"];
        
        // Set start offsets
        _layer1Offset = 200.0f;
        _layer2Offset = 200.0f;
        _layer3Offset = 200.0f;
        _layer4Offset = 200.0f;
        
        // Vertical offsets
        CGFloat layer1VerticalOffset = 0.0f;
        CGFloat layer2VerticalOffset = 0.0f;
        CGFloat layer3VerticalOffset = 0.0f;
        CGFloat layer4VerticalOffset = 0.0f;
        
        _layer1 = [self cloudLayerScrollViewWithRepeatingImage:clouds1];
        _layer1.frame = CGRectMake(0.0f, layer1VerticalOffset, self.frame.size.width, self.frame.size.height);
        _layer1.contentOffset = CGPointMake(_layer1Offset, 0.0f);
        
        _layer2 = [self cloudLayerScrollViewWithRepeatingImage:clouds2];
        _layer2.frame = CGRectMake(0.0f, layer2VerticalOffset, self.frame.size.width, self.frame.size.height);
        _layer2.contentOffset = CGPointMake(_layer2Offset, 0.0f);
        
        _layer3 = [self cloudLayerScrollViewWithRepeatingImage:clouds3];
        _layer3.frame = CGRectMake(0.0f, layer3VerticalOffset, self.frame.size.width, self.frame.size.height);
        _layer3.contentOffset = CGPointMake(_layer3Offset, 0.0f);
        
        _layer4 = [self cloudLayerScrollViewWithRepeatingImage:clouds4];
        _layer4.frame = CGRectMake(0.0f, layer4VerticalOffset, self.frame.size.width, self.frame.size.height);
        _layer4.contentOffset = CGPointMake(_layer4Offset, 0.0f);
        
        [self addSubview:_layer4];
        [self addSubview:_layer3];
        [self addSubview:_layer2];
        [self addSubview:_layer1];
    }
    return self;
}


- (UIScrollView *)cloudLayerScrollViewWithRepeatingImage:(UIImage *)image {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    sv.userInteractionEnabled = NO;
    sv.opaque = NO;
    sv.scrollEnabled = NO;
    sv.showsHorizontalScrollIndicator = NO;
    sv.showsVerticalScrollIndicator = NO;
    sv.bounces = NO;
    UIImageView *firstImage = [[UIImageView alloc] initWithImage:image];
    UIImageView *secondImage = [[UIImageView alloc] initWithImage:image];
    firstImage.contentMode = UIViewContentModeLeft;
    secondImage.contentMode = UIViewContentModeLeft;
    secondImage.frame = CGRectMake(image.size.width, 0.0f, 320.0f, image.size.height);
    [sv addSubview:firstImage];
    [sv addSubview:secondImage];
    sv.contentSize = CGSizeMake(image.size.width + 320.0f, image.size.height);
    return sv;
}


- (void)startAnimating {
    if (!_animationTimer || ![_animationTimer isValid]) {
        _animationTimer = [NSTimer timerWithTimeInterval:0.025 
                                                  target:self 
                                                selector:@selector(animationTick) 
                                                userInfo:nil 
                                                 repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];

    }
}


- (void)stopAnimating {
    [_animationTimer invalidate];
}


- (void)animationTick {
    CGFloat newLayer1Offset = _layer1Offset + ([_animationTimer timeInterval] * LAYER1_SPEED);
    newLayer1Offset = (newLayer1Offset > [_layer1 contentSize].width - 320.0f) ? newLayer1Offset - ([_layer1 contentSize].width - 320.0f):
                                                                                    newLayer1Offset;
    _layer1Offset = newLayer1Offset;
    
    CGFloat newLayer2Offset = _layer2Offset + ([_animationTimer timeInterval] * LAYER2_SPEED);
    newLayer2Offset = (newLayer2Offset > [_layer2 contentSize].width - 320.0f) ? newLayer2Offset - ([_layer2 contentSize].width - 320.0f):
                                                                                    newLayer2Offset;
    _layer2Offset = newLayer2Offset;
    
    CGFloat newLayer3Offset = _layer3Offset + ([_animationTimer timeInterval] * LAYER3_SPEED);
    newLayer3Offset = (newLayer3Offset > [_layer3 contentSize].width - 320.0f) ? newLayer3Offset - ([_layer3 contentSize].width - 320.0f):
                                                                                    newLayer3Offset;
    _layer3Offset = newLayer3Offset;
    
    CGFloat newLayer4Offset = _layer4Offset + ([_animationTimer timeInterval] * LAYER4_SPEED);
    newLayer4Offset = (newLayer4Offset > [_layer4 contentSize].width - 320.0f) ? newLayer4Offset - ([_layer4 contentSize].width - 320.0f):
                                                                                    newLayer4Offset;
    _layer4Offset = newLayer4Offset;
    
    [_layer1 setContentOffset:CGPointMake(newLayer1Offset, 0.0f) animated:NO];
    [_layer2 setContentOffset:CGPointMake(newLayer2Offset, 0.0f) animated:NO];
    [_layer3 setContentOffset:CGPointMake(newLayer3Offset, 0.0f) animated:NO];
    [_layer4 setContentOffset:CGPointMake(newLayer4Offset, 0.0f) animated:NO];
}


- (void)dealloc {
    [_animationTimer invalidate];
}

@end
