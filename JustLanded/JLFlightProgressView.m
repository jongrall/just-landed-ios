//
//  JLFlightProgressView.m
//  JustLanded
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLFlightProgressView.h"

const CGSize FLIGHT_PROGRESS_VIEW_SIZE = {320.0f, 70.0f};
const CGPoint FLIGHT_ICON_CENTER = {31.0f, 30.0f};
const CGSize FLIGHT_ICON_SIZE = {62.0f, 60.0f};
const UIEdgeInsets FLIGHT_ICON_INSETS = {0.0f, 38.0f, 0.0f, 34.0f};
const CGFloat GROUND_LAYER_POINTS_PER_SEC = 25.0f;
const CGFloat CLOUD_LAYER_POINTS_PER_SEC = 40.0f;

@interface JLFlightProgressView () {
    __strong UIImageView *_onGroundBg;
    __strong UIScrollView *_groundLayer;
    __strong UIScrollView *_cloudLayer;
    __strong UIImageView *_airplaneIcon;
    __strong NSTimer *_animationTimer;
    CGFloat _currentGroundOffset;
    CGFloat _currentCloudOffset;
}

- (void)animateProgressBackgrounds;
- (void)updatePlaneIcon;

@end


@implementation JLFlightProgressView

@synthesize progress;
@synthesize timeOfDay;
@synthesize aircraftType;


- (id)initWithFrame:(CGRect)frame 
           progress:(CGFloat)someProgress 
          timeOfDay:(TimeOfDay)tod 
       aircraftType:(AircraftType)aType {
    CGRect fixedSize = CGRectMake(frame.origin.x, 
                                  frame.origin.y, 
                                  FLIGHT_PROGRESS_VIEW_SIZE.width, 
                                  FLIGHT_PROGRESS_VIEW_SIZE.height);
    
    self = [super initWithFrame:fixedSize];
    if (self) {        
        CGRect bgFrame = CGRectMake(0.0f, 
                                    0.0f, 
                                    FLIGHT_PROGRESS_VIEW_SIZE.width, 
                                    FLIGHT_PROGRESS_VIEW_SIZE.height);
        
        _onGroundBg = [[UIImageView alloc] initWithFrame:bgFrame];
        
        _groundLayer = [[UIScrollView alloc] initWithFrame:bgFrame];
        _groundLayer.userInteractionEnabled = NO;
        _groundLayer.opaque = NO;
        _groundLayer.scrollEnabled = NO;
        _groundLayer.showsHorizontalScrollIndicator = NO;
        _groundLayer.showsVerticalScrollIndicator = NO;
        _groundLayer.bounces = NO;
        
        _cloudLayer = [[UIScrollView alloc] initWithFrame:bgFrame];
        _cloudLayer.userInteractionEnabled = NO;
        _cloudLayer.opaque = NO;
        _cloudLayer.scrollEnabled = NO;
        _cloudLayer.showsHorizontalScrollIndicator = NO;
        _cloudLayer.showsVerticalScrollIndicator = NO;
        _cloudLayer.bounces = NO;
        
        _airplaneIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:_onGroundBg];
        [self addSubview:_groundLayer];
        [self addSubview:_cloudLayer];
        [self addSubview:_airplaneIcon];
        
        self.timeOfDay = tod;
        self.aircraftType = aType;
        self.progress = progress;
    }
    return self;
}


- (void)setProgress:(CGFloat)newProgress {
    // Force the progress value between 0.0 and 1.0
    if (newProgress < 0.0f) {
        newProgress = 0.0f;
    }
    else if (newProgress > 1.0f) {
        newProgress = 1.0f;
    }
        
    progress = newProgress;
    
    // Hide/show the appropriate backgrounds
    // If progress = 0 or 1.0, show the flight landed background
    if (progress == 0.0f || progress == 1.0f) {
        // Stop the timer if necessary
        if ([_animationTimer isValid]) {
            [_animationTimer invalidate];
        }
        
        if (timeOfDay == DAY) {
            _onGroundBg.image = [UIImage imageNamed:@"flight_on_ground_day"];
        }
        else {
            _onGroundBg.image = [UIImage imageNamed:@"flight_on_ground_night"];
        }
        
        _onGroundBg.hidden = NO;
        _groundLayer.hidden = YES;
        _cloudLayer.hidden = YES;
        _airplaneIcon.hidden = YES;
    }
    else {
        // Update the flight icon position
        CGFloat horizontalOffset = (FLIGHT_ICON_INSETS.left - FLIGHT_ICON_CENTER.x +
                                    ((FLIGHT_PROGRESS_VIEW_SIZE.width - FLIGHT_ICON_INSETS.left - FLIGHT_ICON_INSETS.right) * progress));
        CGFloat verticalOffset = (FLIGHT_PROGRESS_VIEW_SIZE.height / 2.0f) - FLIGHT_ICON_CENTER.y;
        
        _airplaneIcon.frame = CGRectMake(horizontalOffset, verticalOffset, FLIGHT_ICON_SIZE.width, FLIGHT_ICON_SIZE.height);
        
        _onGroundBg.hidden = YES;
        _groundLayer.hidden = NO;
        _cloudLayer.hidden = NO;
        _airplaneIcon.hidden = NO;
    
        // Start the timer if necessary
        if (!_animationTimer || ![_animationTimer isValid]) {
            _animationTimer = [NSTimer timerWithTimeInterval:0.025 
                                                      target:self
                                                    selector:@selector(animateProgressBackgrounds)
                                                    userInfo:nil 
                                                     repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
            [_animationTimer fire];
        }
    }
}


- (void)setTimeOfDay:(TimeOfDay)newTimeOfDay {
    timeOfDay = newTimeOfDay;
    
    // Update the backgrounds and flight icon
    UIImage *groundBg = nil;
    UIImage *cloudBg = nil;
    
    // Remove all subviews of the ground and cloud layers
    for (UIView *aView in [_groundLayer subviews]) {
        [aView removeFromSuperview];
    }
    
    for (UIView *aView in [_cloudLayer subviews]) {
        [aView removeFromSuperview];
    }
    
    if (timeOfDay == DAY) {
        groundBg = [UIImage imageNamed:@"tracking_animation_ground_day"];
        cloudBg = [UIImage imageNamed:@"tracking_animation_clouds_day"];
    }
    else {
        groundBg = [UIImage imageNamed:@"tracking_animation_ground_night"];
        cloudBg = [UIImage imageNamed:@"tracking_animation_clouds_night"];
    }
    
    BOOL zeroContentSize = CGSizeEqualToSize(_groundLayer.contentSize, CGSizeZero);
    
    UIImageView *groundImage1 = [[UIImageView alloc] initWithImage:groundBg];
    UIImageView *groundImage2 = [[UIImageView alloc] initWithImage:groundBg];
    groundImage2.contentMode = UIViewContentModeLeft;
    groundImage2.frame = CGRectMake(groundBg.size.width, 0.0f, 320.0f, groundBg.size.height);
    
    UIImageView *cloudImage1 = [[UIImageView alloc] initWithImage:cloudBg];
    UIImageView *cloudImage2 = [[UIImageView alloc] initWithImage:cloudBg];
    cloudImage2.contentMode = UIViewContentModeLeft;
    cloudImage2.frame = CGRectMake(cloudBg.size.width, 0.0f, 320.0f, cloudBg.size.height);
    
    [_groundLayer addSubview:groundImage1];
    [_groundLayer addSubview:groundImage2];
    [_cloudLayer addSubview:cloudImage1];
    [_cloudLayer addSubview:cloudImage2];

    _groundLayer.contentSize = CGSizeMake(groundBg.size.width + 320.0f, groundBg.size.height); // 320.0f added for seamless looping
    _cloudLayer.contentSize = CGSizeMake(cloudBg.size.width + 320.0f, cloudBg.size.height); // 320.0f added for seamless looping
        
    if (zeroContentSize) {
        // Randomize the start point
        CGFloat randomOffset = (float) (arc4random() % ((int) _groundLayer.contentSize.width));
        _currentGroundOffset = randomOffset;
        [_groundLayer setContentOffset:CGPointMake(randomOffset, 0.0f) animated:NO];
        randomOffset = (float) (arc4random() % ((int) _cloudLayer.contentSize.width));
        _currentCloudOffset = randomOffset;
        [_cloudLayer setContentOffset:CGPointMake(randomOffset, 0.0f) animated:NO];
    }
    
    [self updatePlaneIcon];
    
    // Because the icons may have changed size, set progress again
    [self setProgress:progress];
}


- (void)setAircraftType:(AircraftType)newAircraftType {
    aircraftType = newAircraftType;
    
    [self updatePlaneIcon];
        
    // Because the icons may have changed size, set progress again
    [self setProgress:progress];
}


- (void)animateProgressBackgrounds {
    CGFloat newGroundOffset;
    CGFloat newCloudOffset;
        
    if (_currentGroundOffset >= _groundLayer.contentSize.width - 320.0f) {
        newGroundOffset = (_currentGroundOffset - (_groundLayer.contentSize.width - 320.0f)) + (GROUND_LAYER_POINTS_PER_SEC * _animationTimer.timeInterval);
    }
    else {
        newGroundOffset = _currentGroundOffset + (GROUND_LAYER_POINTS_PER_SEC * _animationTimer.timeInterval);
    }

    if (_currentCloudOffset >= _cloudLayer.contentSize.width - 320.0f) {
        newCloudOffset = (_currentCloudOffset - (_cloudLayer.contentSize.width - 320.0f)) + (CLOUD_LAYER_POINTS_PER_SEC * _animationTimer.timeInterval);
    }
    else {
        newCloudOffset = _currentCloudOffset + (CLOUD_LAYER_POINTS_PER_SEC * _animationTimer.timeInterval);
    }
    
    _currentGroundOffset = newGroundOffset;
    _currentCloudOffset = newCloudOffset;
    
    [_groundLayer setContentOffset:CGPointMake(newGroundOffset, 0.0f) animated:NO];
    [_cloudLayer setContentOffset:CGPointMake(newCloudOffset, 0.0f) animated:NO];
}


- (void)updatePlaneIcon {
    // Update the icon based on the time of day and aircraft type
    // Update the backgrounds and flight icon
    if (timeOfDay == DAY) {
        NSString *airplaneIconName = [NSString stringWithFormat:@"%@_day", [Flight aircraftTypeToString:aircraftType]];
        UIImage *planeIcon = [UIImage imageNamed:airplaneIconName];
        _airplaneIcon.image = planeIcon;
        [_airplaneIcon stopAnimating];
        _airplaneIcon.animationImages = nil;
    }
    else {
        NSString *airplaneIconName = [NSString stringWithFormat:@"%@_night", [Flight aircraftTypeToString:aircraftType]];
        NSString *airplaneLightsIconName = [NSString stringWithFormat:@"%@_night_lights", [Flight aircraftTypeToString:aircraftType]];
        UIImage *planeIcon = [UIImage imageNamed:airplaneIconName];
        UIImage *planeLightsIcon = [UIImage imageNamed:airplaneLightsIconName];
        _airplaneIcon.animationImages = [NSArray arrayWithObjects:planeIcon, 
                                                                  planeIcon, 
                                                                  planeIcon, 
                                                                  planeIcon, 
                                                                  planeIcon, 
                                                                  planeIcon, 
                                                                  planeIcon, 
                                                                  planeIcon, 
                                                                  planeIcon, 
                                                                  planeLightsIcon, nil];
        _airplaneIcon.image = nil;
        _airplaneIcon.animationDuration = 2.5;
        [_airplaneIcon startAnimating];
    }
    
    _airplaneIcon.frame = CGRectMake(_airplaneIcon.frame.origin.x, 
                                     _airplaneIcon.frame.origin.y,
                                     FLIGHT_ICON_SIZE.width, 
                                     FLIGHT_ICON_SIZE.height);
}


- (void)stopAnimating {
    [_animationTimer invalidate];
}


- (void)dealloc {
    [self stopAnimating];
}

@end