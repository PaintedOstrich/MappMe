//
//  ListViewController.h
//  MappMe
//
//  Created by #BAL on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;
@interface ListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    Place *selectedCity;
}

@property(nonatomic,strong)	Place *selectedCity;
@end
