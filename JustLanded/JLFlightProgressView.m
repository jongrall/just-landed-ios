//
//  JLFlightProgressView.m
//  Just Landed
//
//  Created by Jon Grall on 4/16/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import "JLFlightProgressView.h"

const CGPoint FLIGHT_ICON_CENTER = {31.0f, 30.0f};
const CGSize FLIGHT_ICON_SIZE = {62.0f, 60.0f};
const UIEdgeInsets FLIGHT_ICON_INSETS = {0.0f, 38.0f, 0.0f, 34.0f};
const CGFloat GROUND_LAYER_POINTS_PER_SEC = 25.0f;
const CGFloat CLOUD_LAYER_POINTS_PER_SEC = 40.0f;

@interface JLFlightProgressView ()

@property (strong, nonatomic) UIImageView *onGroundBackground_;
@property (strong, nonatomic) UIScrollView *groundLayer_;
@property (strong, nonatomic) UIScrollView *cloudLayer_;
@property (strong, nonatomic) UIImageView *airplaneIcon_;
@property (strong, nonatomic) NSTimer *animationTimer_;
@property (nonatomic) CGFloat currentGroundOffset_;
@property (nonatomic) CGFloat currentCloudOffset_;

+ (CGSize)flightProgressViewSize;
- (void)animateProgressBackgrounds;
- (void)updatePlaneIcon;

@end


@implementation JLFlightProgressView

@synthesize onGroundBackground_;
@synthesize groundLayer_;
@synthesize cloudLayer_;
@synthesize airplaneIcon_;
@synthesize animationTimer_;
@synthesize currentGroundOffset_;
@synthesize currentCloudOffset_;
@synthesize progress = progress_;
@synthesize timeOfDay = timeOfDay_;
@synthesize aircraftType = aircraftType_;

+ (CGSize)flightProgressViewSize {
    return [UIScreen isMainScreenWide] ? (CGSize) {320.0f, 104.0f} : (CGSize) {320.0f, 70.0f};
}

- (id)initWithFrame:(CGRect)aFrame
           progress:(CGFloat)someProgress 
          timeOfDay:(TimeOfDay)aTimeOfDay
       aircraftType:(AircraftType)aType {
    CGSize viewSize = [[self class] flightProgressViewSize];
    CGRect fixedFrame = CGRectMake(aFrame.origin.x,
                                   aFrame.origin.y, 
                                   viewSize.width,
                                   viewSize.height);
    
    self = [super initWithFrame:fixedFrame];
    if (self) {        
        CGRect bgFrame = CGRectMake(0.0f, 
                                    0.0f, 
                                    viewSize.width,
                                    viewSize.height);
        
        onGroundBackground_ = [[UIImageView alloc] initWithFrame:bgFrame];
        
        groundLayer_ = [[UIScrollView alloc] initWithFrame:bgFrame];
        groundLayer_.userInteractionEnabled = NO;
        groundLayer_.opaque = NO;
        groundLayer_.scrollEnabled = NO;
        groundLayer_.showsHorizontalScrollIndicator = NO;
        groundLayer_.showsVerticalScrollIndicator = NO;
        groundLayer_.bounces = NO;
        
        cloudLayer_ = [[UIScrollView alloc] initWithFrame:bgFrame];
        cloudLayer_.userInteractionEnabled = NO;
        cloudLayer_.opaque = NO;
        cloudLayer_.scrollEnabled = NO;
        cloudLayer_.showsHorizontalScrollIndicator = NO;
        cloudLayer_.showsVerticalScrollIndicator = NO;
        cloudLayer_.bounces = NO;
        
        airplaneIcon_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:onGroundBackground_];
        [self addSubview:groundLayer_];
        [self addSubview:cloudLayer_];
        [self addSubview:airplaneIcon_];
        
        timeOfDay_ = aTimeOfDay;
        aircraftType_ = aType;
        progress_ = someProgress;
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
        
    progress_ = newProgress;
    
    // Hide/show the appropriate backgrounds
    // If progress = 0 or 1.0, show the flight landed background
    if (progress_ == 0.0f || progress_ == 1.0f) {
        // Stop the timer if necessary
        if ([self.animationTimer_ isValid]) {
            [self.animationTimer_ invalidate];
        }
        
        if (self.timeOfDay == DAY) {
            self.onGroundBackground_.image = [UIImage imageNamed:[@"flight_on_ground_day" imageName]];
        }
        else {
            self.onGroundBackground_.image = [UIImage imageNamed:[@"flight_on_ground_night" imageName]];
        }
        
        self.onGroundBackground_.hidden = NO;
        self.groundLayer_.hidden = YES;
        self.cloudLayer_.hidden = YES;
        self.airplaneIcon_.hidden = YES;
    }
    else {
        // Update the flight icon position
        CGSize viewSize = [[self class] flightProgressViewSize];
        CGFloat horizontalOffset = (FLIGHT_ICON_INSETS.left - FLIGHT_ICON_CENTER.x +
                                    ((viewSize.width - FLIGHT_ICON_INSETS.left - FLIGHT_ICON_INSETS.right) * progress_));
        CGFloat verticalOffset = (viewSize.height / 2.0f) - FLIGHT_ICON_CENTER.y;
        
        self.airplaneIcon_.frame = CGRectMake(horizontalOffset, verticalOffset, FLIGHT_ICON_SIZE.width, FLIGHT_ICON_SIZE.height);
        
        self.onGroundBackground_.hidden = YES;
        self.groundLayer_.hidden = NO;
        self.cloudLayer_.hidden = NO;
        self.airplaneIcon_.hidden = NO;
    
        // Start the timer if necessary
        if (!self.animationTimer_ || ![self.animationTimer_ isValid]) {
            [self.animationTimer_ invalidate];
            self.animationTimer_ = [NSTimer timerWithTimeInterval:0.025 
                                                           target:self
                                                         selector:@selector(animateProgressBackgrounds)
                                                         userInfo:nil 
                                                          repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.animationTimer_ forMode:NSRunLoopCommonModes];
            [self.animationTimer_ fire];
        }
    }
}


- (void)setTimeOfDay:(TimeOfDay)newTimeOfDay {
    timeOfDay_ = newTimeOfDay;
    
    // Updale the backgrounds and flight icon
    UIImage *groundBg = nil;
    UIImage *cloudBg = nil;
    
    // Remove all subviews of the ground and cloud layers
    for (UIView *aView in [self.groundLayer_ subviews]) {
        [aView removeFromSuperview];
    }
    
    for (UIView *aView in [self.cloudLayer_ subviews]) {
        [aView removeFromSuperview];
    }
    
    if (timeOfDay_ == DAY) {
        groundBg = [UIImage imageNamed:[@"tracking_animation_ground_day" imageName]];
        cloudBg = [UIImage imageNamed:[@"tracking_animation_clouds_day" imageName]];
    }
    else {
        groundBg = [UIImage imageNamed:[@"tracking_animation_ground_night" imageName]];
        cloudBg = [UIImage imageNamed:[@"tracking_animation_clouds_night" imageName]];
    }
    
    BOOL zeroContentSize = CGSizeEqualToSize(self.groundLayer_.contentSize, CGSizeZero);
    
    UIImageView *groundImage1 = [[UIImageView alloc] initWithImage:groundBg];
    UIImageView *groundImage2 = [[UIImageView alloc] initWithImage:groundBg];
    groundImage2.contentMode = UIViewContentModeLeft;
    groundImage2.frame = CGRectMake(groundBg.size.width, 0.0f, 320.0f, groundBg.size.height);
    
    UIImageView *cloudImage1 = [[UIImageView alloc] initWithImage:cloudBg];
    UIImageView *cloudImage2 = [[UIImageView alloc] initWithImage:cloudBg];
    cloudImage2.contentMode = UIViewContentModeLeft;
    cloudImage2.frame = CGRectMake(cloudBg.size.width, 0.0f, 320.0f, cloudBg.size.height);
    
    [self.groundLayer_ addSubview:groundImage1];
    [self.groundLayer_ addSubview:groundImage2];
    [self.cloudLayer_ addSubview:cloudImage1];
    [self.cloudLayer_ addSubview:cloudImage2];

    self.groundLayer_.contentSize = CGSizeMake(groundBg.size.width + 320.0f, groundBg.size.height); // 320.0f added for seamless looping
    self.cloudLayer_.contentSize = CGSizeMake(cloudBg.size.width + 320.0f, cloudBg.size.height); // 320.0f added for seamless looping
        
    if (zeroContentSize) {
        // Randomize the start point
        CGFloat randomOffset = (float) (arc4random() % ((int) self.groundLayer_.contentSize.width));
        self.currentGroundOffset_ = randomOffset;
        [self.groundLayer_ setContentOffset:CGPointMake(randomOffset, 0.0f) animated:NO];
        randomOffset = (float) (arc4random() % ((int) self.cloudLayer_.contentSize.width));
        self.currentCloudOffset_ = randomOffset;
        [self.cloudLayer_ setContentOffset:CGPointMake(randomOffset, 0.0f) animated:NO];
    }
    
    [self updatePlaneIcon];
    
    // Because the icons may have changed size, set progress again
    [self setProgress:self.progress];
}


- (void)setAircraftType:(AircraftType)newAircraftType {
    aircraftType_ = newAircraftType;
    
    [self updatePlaneIcon];
        
    // Because the icons may have changed size, set progress again
    [self setProgress:self.progress];
}


- (void)animateProgressBackgrounds {
    CGFloat newGroundOffset;
    CGFloat newCloudOffset;
        
    if (currentGroundOffset_ >= groundLayer_.contentSize.width - 320.0f) {
        newGroundOffset = (currentGroundOffset_ - (groundLayer_.contentSize.width - 320.0f)) + (GROUND_LAYER_POINTS_PER_SEC * animationTimer_.timeInterval);
    }
    else {
        newGroundOffset = currentGroundOffset_ + (GROUND_LAYER_POINTS_PER_SEC * animationTimer_.timeInterval);
    }

    if (self.currentCloudOffset_ >= cloudLayer_.contentSize.width - 320.0f) {
        newCloudOffset = (currentCloudOffset_ - (cloudLayer_.contentSize.width - 320.0f)) + (CLOUD_LAYER_POINTS_PER_SEC * animationTimer_.timeInterval);
    }
    else {
        newCloudOffset = currentCloudOffset_ + (CLOUD_LAYER_POINTS_PER_SEC * animationTimer_.timeInterval);
    }
    
    self.currentGroundOffset_ = newGroundOffset;
    self.currentCloudOffset_ = newCloudOffset;
    
    [self.groundLayer_ setContentOffset:CGPointMake(newGroundOffset, 0.0f) animated:NO];
    [self.cloudLayer_ setContentOffset:CGPointMake(newCloudOffset, 0.0f) animated:NO];
}


- (void)updatePlaneIcon {
    // Update the icon based on the time of day and aircraft type
    // Update the backgrounds and flight icon
    if (self.timeOfDay == DAY) {
        NSString *airplaneIconName = [NSString stringWithFormat:@"%@_day", [Flight aircraftTypeToString:self.aircraftType]];
        UIImage *planeIcon = [UIImage imageNamed:airplaneIconName];
        self.airplaneIcon_.image = planeIcon;
        [self.airplaneIcon_ stopAnimating];
        self.airplaneIcon_.animationImages = nil;
    }
    else {
        NSString *airplaneIconName = [NSString stringWithFormat:@"%@_night", [Flight aircraftTypeToString:self.aircraftType]];
        NSString *airplaneLightsIconName = [NSString stringWithFormat:@"%@_night_lights", [Flight aircraftTypeToString:self.aircraftType]];
        UIImage *planeIcon = [UIImage imageNamed:airplaneIconName];
        UIImage *planeLightsIcon = [UIImage imageNamed:airplaneLightsIconName];
        self.airplaneIcon_.animationImages = @[planeIcon, 
                                                                    planeIcon,
                                                                    planeIcon,
                                                                    planeIcon,
                                                                    planeIcon,
                                                                    planeIcon,
                                                                    planeIcon,
                                                                    planeIcon,
                                                                    planeIcon,
                                                                    planeLightsIcon];
        self.airplaneIcon_.image = nil;
        self.airplaneIcon_.animationDuration = 2.5;
        [self.airplaneIcon_ startAnimating];
    }
    
    self.airplaneIcon_.frame = CGRectMake(self.airplaneIcon_.frame.origin.x, 
                                          self.airplaneIcon_.frame.origin.y,
                                          FLIGHT_ICON_SIZE.width, 
                                          FLIGHT_ICON_SIZE.height);
}


- (void)stopAnimating {
    [self.animationTimer_ invalidate];
}


- (void)removeFromSuperview {
    [self.animationTimer_ invalidate]; // Stop the timer, to avoid retain timer retaining us if dev forgot to stop animating
    [super removeFromSuperview];
}

@end
