//
//  AirlineLookupViewController.h
//  Just Landed
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 Little Details LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AirlineLookupDelegate
- (void)didChooseAirlineCode:(NSString *)airlineCode;
- (void)cancelledAirlineLookup;
@end


@interface AirlineLookupViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id <AirlineLookupDelegate> delegate;

+ (BOOL)airlineCodeExists:(NSString *)aCode;

@end
