//
//  AirlineLookupViewController.h
//  JustLanded
//
//  Created by Jon Grall on 6/12/12.
//  Copyright (c) 2012 SimplyListed. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AirlineLookupDelegate
- (void)didChooseAirlineCode:(NSString *)airlineCode;
- (void)cancelledAirlineLookup;
@end


@interface AirlineLookupViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id <AirlineLookupDelegate> delegate;

@end
