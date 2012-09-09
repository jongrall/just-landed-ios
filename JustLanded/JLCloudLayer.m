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


@interface JLCloudLayer ()

@property (strong, nonatomic) UIScrollView *layer1_;
@property (strong, nonatomic) UIScrollView *layer2_;
@property (strong, nonatomic) UIScrollView *layer3_;
@property (strong, nonatomic) UIScrollView *layer4_;
@property (strong, nonatomic) NSTimer *animationTimer_;
@property (nonatomic) CGFloat layer1Offset_;
@property (nonatomic) CGFloat layer2Offset_;
@property (nonatomic) CGFloat layer3Offset_;
@property (nonatomic) CGFloat layer4Offset_;

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
        self.layer1Offset_ = 200.0f;
        self.layer2Offset_ = 200.0f;
        self.layer3Offset_ = 200.0f;
        self.layer4Offset_ = 200.0f;
                
        self.layer1_ = [self cloudLayerScrollViewWithRepeatingImage:clouds1];
        self.layer1_.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        self.layer1_.contentOffset = CGPointMake(self.layer1Offset_, 0.0f);
        
        self.layer2_ = [self cloudLayerScrollViewWithRepeatingImage:clouds2];
        self.layer2_.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        self.layer2_.contentOffset = CGPointMake(self.layer2Offset_, 0.0f);
        
        self.layer3_ = [self cloudLayerScrollViewWithRepeatingImage:clouds3];
        self.layer3_.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        self.layer3_.contentOffset = CGPointMake(self.layer3Offset_, 0.0f);
        
        self.layer4_ = [self cloudLayerScrollViewWithRepeatingImage:clouds4];
        self.layer4_.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        self.layer4_.contentOffset = CGPointMake(self.layer4Offset_, 0.0f);
        
        [self addSubview:self.layer4_];
        [self addSubview:self.layer3_];
        [self addSubview:self.layer2_];
        [self addSubview:self.layer1_];
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
    UIImageView *firstImage = [[UIImageView alloc] initWithImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height - 1.0f, 0.0f, 1.0f, 0.0f)]];
    UIImageView *secondImage = [[UIImageView alloc] initWithImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height - 1.0f, 0.0f, 1.0f, 0.0f)]];
    firstImage.frame = CGRectMake(0.0f, 0.0f, 320.0f, self.frame.size.height);
    secondImage.frame = CGRectMake(image.size.width, 0.0f, 320.0f, self.frame.size.height);
    [sv addSubview:firstImage];
    [sv addSubview:secondImage];
    sv.contentSize = CGSizeMake(image.size.width + 320.0f, self.frame.size.height);
    return sv;
}


- (void)startAnimating {
    if (!self.animationTimer_ || ![self.animationTimer_ isValid]) {
        self.animationTimer_ = [NSTimer timerWithTimeInterval:0.025 
                                                       target:self 
                                                     selector:@selector(animationTick) 
                                                     userInfo:nil 
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.animationTimer_ forMode:NSRunLoopCommonModes];

    }
}


- (void)stopAnimating {
    [self.animationTimer_ invalidate];
}


- (void)animationTick {
    CGFloat newLayer1Offset = self.layer1Offset_ + ([self.animationTimer_ timeInterval] * LAYER1_SPEED);
    newLayer1Offset = (newLayer1Offset > [self.layer1_ contentSize].width - 320.0f) ? newLayer1Offset - ([self.layer1_ contentSize].width - 320.0f):
                                                                                    newLayer1Offset;
    self.layer1Offset_ = newLayer1Offset;
    
    CGFloat newLayer2Offset = self.layer2Offset_ + ([self.animationTimer_ timeInterval] * LAYER2_SPEED);
    newLayer2Offset = (newLayer2Offset > [self.layer2_ contentSize].width - 320.0f) ? newLayer2Offset - ([self.layer2_ contentSize].width - 320.0f):
                                                                                    newLayer2Offset;
    self.layer2Offset_ = newLayer2Offset;
    
    CGFloat newLayer3Offset = self.layer3Offset_ + ([self.animationTimer_ timeInterval] * LAYER3_SPEED);
    newLayer3Offset = (newLayer3Offset > [self.layer3_ contentSize].width - 320.0f) ? newLayer3Offset - ([self.layer3_ contentSize].width - 320.0f):
                                                                                    newLayer3Offset;
    self.layer3Offset_ = newLayer3Offset;
    
    CGFloat newLayer4Offset = self.layer4Offset_ + ([self.animationTimer_ timeInterval] * LAYER4_SPEED);
    newLayer4Offset = (newLayer4Offset > [self.layer4_ contentSize].width - 320.0f) ? newLayer4Offset - ([self.layer4_ contentSize].width - 320.0f):
                                                                                    newLayer4Offset;
    self.layer4Offset_ = newLayer4Offset;
    
    [self.layer1_ setContentOffset:CGPointMake(newLayer1Offset, 0.0f) animated:NO];
    [self.layer2_ setContentOffset:CGPointMake(newLayer2Offset, 0.0f) animated:NO];
    [self.layer3_ setContentOffset:CGPointMake(newLayer3Offset, 0.0f) animated:NO];
    [self.layer4_ setContentOffset:CGPointMake(newLayer4Offset, 0.0f) animated:NO];
}


- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    self.layer1_.frame = CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height);
    self.layer2_.frame = CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height);
    self.layer3_.frame = CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height);
    self.layer4_.frame = CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height);
}


- (NSArray *)currentCloudOffsets {
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:self.layer1Offset_],
            [NSNumber numberWithFloat:self.layer2Offset_],
            [NSNumber numberWithFloat:self.layer3Offset_],
            [NSNumber numberWithFloat:self.layer4Offset_], nil];
}


- (void)setCurrentCloudOffsets:(NSArray *)someOffsets {
    NSAssert(someOffsets && [someOffsets count] == 4, @"Missing required number of offsets.");
    self.layer1Offset_ = [[someOffsets objectAtIndex:0] floatValue];
    self.layer2Offset_ = [[someOffsets objectAtIndex:1] floatValue];
    self.layer3Offset_ = [[someOffsets objectAtIndex:2] floatValue];
    self.layer4Offset_ = [[someOffsets objectAtIndex:3] floatValue];
    [self.layer1_ setContentOffset:CGPointMake(self.layer1Offset_, 0.0f) animated:NO];
    [self.layer2_ setContentOffset:CGPointMake(self.layer2Offset_, 0.0f) animated:NO];
    [self.layer3_ setContentOffset:CGPointMake(self.layer3Offset_, 0.0f) animated:NO];
    [self.layer4_ setContentOffset:CGPointMake(self.layer4Offset_, 0.0f) animated:NO];
}


- (void)dealloc {
    [self.animationTimer_ invalidate];
}

@end
