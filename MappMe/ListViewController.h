//
//  ListViewController.h
//  MappMe
//
//  Created by #BAL on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    NSString *selectedCity;
}

@property(nonatomic,retain)	NSString *selectedCity;
@end
